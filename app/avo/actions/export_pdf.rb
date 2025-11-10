class ExportPdf < Avo::BaseAction
  self.name = "Export PDF"
  self.may_download_file = true

  def handle(models:, resource:, **)
    require 'prawn'
    require 'prawn/table'

    pdf = Prawn::Document.new

    timestamp = (Time.zone&.now || Time.now).strftime("%Y-%m-%d")
    filename = "#{resource.plural_name.parameterize(separator: '_')}_#{timestamp}.pdf"

    # Expand incoming models (CustomerOrder | CustomerBox | Box) into an array of CustomerOrder
    orders = models.flat_map do |m|
      extract_orders_from_record(m)
    end

    # If the action was invoked on CustomerBox rows, render a compact subscription-focused table
    if models.any? { |m| m.class.name == "CustomerBox" }
      render_subscription_table(pdf, orders)
    else
      render_detailed_orders(pdf, orders)
    end

    download pdf.render, filename
  end

  private

  def render_subscription_table(pdf, orders)
    pdf.font_size 10

    # Table header
    headers = ["Name", "Address", "Fulfillment", "Add'l Variations", "Notes"]

    data = [headers]

    orders.each do |order|
      next unless order.present?

      all_orderables = order.respond_to?(:orderables) ? order.orderables.to_a : []

      # Current subscription orderables: have subscription_id and are current (or lack 'current' flag)
      current_subs = all_orderables.select do |o|
        o.respond_to?(:subscription_id) && o.subscription_id.present? &&
          (!o.respond_to?(:current) || o.current)
      end

      # Pick a single active subscription (prefer first current_subs)
      active_subscription = current_subs.first

      subscription_label = if active_subscription
                             var_name = active_subscription.variation&.name || "Subscription"
                             qty = (active_subscription.respond_to?(:quantity) && active_subscription.quantity) || (active_subscription.respond_to?(:qty) && active_subscription.qty) || ""
                             qty.present? ? "#{var_name} (#{qty})" : var_name
                           else
                             "No active subscription"
                           end

      name = "#{order.customer&.name || 'N/A'} — #{subscription_label}"
      address = format_address(order.address)
      fulfillment = order.fulfillment_method || "N/A"

      # Add'l variations: include only non-recurring orderables (no subscription_id)
      addl = all_orderables.select { |o| !(o.respond_to?(:subscription_id) && o.subscription_id.present?) }
                          .map { |o| o.variation&.name }.compact.uniq.join(", ")
      addl = addl.presence || ""

      notes_parts = []
      notes_parts << order.description if order.respond_to?(:description) && order.description.present?
      if all_orderables.any?
        orderable_notes = all_orderables.map { |o| o.respond_to?(:notes) ? o.notes.to_s.strip : nil }.compact.reject(&:empty?).uniq.join(" | ")
        notes_parts << orderable_notes if orderable_notes.present?
      end
      notes = notes_parts.join(" — ")

      data << [name, address, fulfillment, addl, notes]
    end

    # Compute column widths to fit page (keeps previous dynamic-scaling approach)
    default_widths = [140.0, 180.0, 80.0, 110.0, 120.0]
    available = pdf.bounds.width.to_f
    total = default_widths.sum

    scaled_widths = if total > 0
      if total > available
        ratio = available / total
        widths = default_widths.map { |w| (w * ratio).floor }
        # distribute any remainder to columns to ensure sum == available (avoid off-by-one)
        rem = (available - widths.sum).to_i
        i = 0
        while rem > 0
          widths[i % widths.length] += 1
          i += 1
          rem -= 1
        end
        widths
      else
        # if there's more room than the defaults, use defaults but expand last column to fill available
        extra = (available - total).to_i
        widths = default_widths.map(&:to_i)
        widths[-1] += extra
        widths
      end
    else
      # fallback: evenly distribute
      count = headers.size
      Array.new(count, (available / count).floor)
    end

    table_options = {
      header: true,
      row_colors: ["FFFFFF", "F7F7F7"],
      cell_style: { inline_format: false, size: 9, overflow: :truncate },
      column_widths: scaled_widths
    }

    # If there are no rows besides the header, add a placeholder
    if data.size == 1
      pdf.text "No subscription orders found for the selected boxes.", size: 10
      return
    end

    pdf.table(data, table_options)
  end

  def render_detailed_orders(pdf, orders)
    pdf.font_size 11

    orders.each do |order|
      pdf.text (order.created_at ? order.created_at.strftime("%B %d, %Y %l:%M %p") : "")
      pdf.text "#{order.customer&.name || 'N/A'}", style: :bold
      pdf.text format_address(order.address)
      pdf.text "Fulfillment Method: #{order.fulfillment_method || 'N/A'}"
      pdf.move_down 5

      if order.respond_to?(:orderables) && order.orderables.any?
        data = [["Qty", "Item"]]
        data += order.orderables.map do |o|
          variation = o.variation
          name = variation&.name || "N/A"
          notes = (o.respond_to?(:notes) && o.notes) || ""
          unit_qty = variation&.unit_quantity || ""
          qty = (o.respond_to?(:quantity) && o.quantity) || (o.respond_to?(:qty) && o.qty) || "1"
          item_label = unit_qty.present? ? "#{unit_qty} x #{name} #{notes}" : "#{name} #{notes}".strip
          [ qty, item_label ]
        end
        pdf.table(data, header: false)
      else
        pdf.text "No orderables."
      end

      pdf.move_down 5
      pdf.stroke_horizontal_rule
      pdf.move_down 5
    end
  end

  # Convert incoming record to an array of CustomerOrder objects.
  # Supports: CustomerOrder, CustomerBox (HABTM to CustomerOrder), Box -> customer_boxes -> customer_orders
  def extract_orders_from_record(record)
    # CustomerOrder: return as-is
    return [record] if record.is_a?(CustomerOrder)

    # CustomerBox: return its customer_orders (eager-load orderables/variation to reduce N+1)
    if record.class.name == "CustomerBox" && record.respond_to?(:customer_orders)
      begin
        return record.customer_orders.includes(:customer, :address, orderables: :variation).to_a
      rescue => e
        Rails.logger.info "[ExportPdf] eager-load failed for CustomerBox ##{record.try(:id)}: #{e.message}"
        return record.customer_orders.to_a
      end
    end

    # Box: expand to customer_boxes, then their customer_orders
    if record.is_a?(Box) && record.respond_to?(:customer_boxes)
      return record.customer_boxes.flat_map do |customer_box|
        begin
          customer_box.customer_orders.includes(:customer, :address, orderables: :variation).to_a
        rescue
          customer_box.customer_orders.to_a
        end
      end.compact
    end

    # Fallback: if it looks like an order, return it; else return empty array
    if record.respond_to?(:orderables) || record.respond_to?(:customer)
      [record]
    else
      []
    end
  end

  def format_address(address)
    return "" unless address
    if address.respond_to?(:full_address) && address.full_address.present?
      address.full_address.to_s
    elsif address.respond_to?(:street) || address.respond_to?(:street_1)
      parts = []
      parts << address.try(:street_1) if address.respond_to?(:street_1) && address.try(:street_1).present?
      parts << address.try(:street) if address.respond_to?(:street) && address.try(:street).present?
      parts << [address.try(:city), address.try(:state), address.try(:postal) || address.try(:zipcode)].compact.join(", ")
      parts.compact.join(" / ")
    elsif address.is_a?(Hash)
      [address[:street] || address["street"], address[:city], address[:state], address[:postal] || address[:zipcode]].compact.join(", ")
    else
      address.to_s
    end
  end
end