class ExportPdf < Avo::BaseAction
  self.name = "Export PDF"
  self.may_download_file = true

  def handle(models:, resource:, **)
    require 'prawn'
    require 'prawn/table'

    pdf = Prawn::Document.new

    # Expand incoming models (CustomerOrder | CustomerBox | Box) into an array of CustomerOrder
    orders = models.flat_map do |m|
      extract_orders_from_record(m)
    end

    orders.each do |order|
      pdf.text (order.created_at ? order.created_at.strftime("%B %d, %Y %l:%M %p") : "Unknown date")
      pdf.text "#{order.customer&.name || 'N/A'}", style: :bold
      pdf.text "#{order.address&.full_address || order.address.to_s || 'N/A'}"
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
        # allow table to size automatically; keep header row display off
        pdf.table(data, header: false)
      else
        pdf.text "No orderables."
      end

      pdf.move_down 5
      pdf.stroke_horizontal_rule
      pdf.move_down 5
    end

    download pdf.render, "customer_orders.pdf"
  end

  private

  # Convert incoming record to an array of CustomerOrder objects.
  # Supports: CustomerOrder, CustomerBox (HABTM to CustomerOrder), Box -> customer_boxes -> customer_orders
  def extract_orders_from_record(record)
    # CustomerOrder: return as-is
    return [record] if record.is_a?(CustomerOrder)

    # CustomerBox: return its customer_orders (eager-load orderables/variation to reduce N+1)
    if record.class.name == "CustomerBox" && record.respond_to?(:customer_orders)
      begin
        return record.customer_orders.includes(orderables: :variation).to_a
      rescue => e
        Rails.logger.info "[ExportPdf] eager-load failed for CustomerBox ##{record.try(:id)}: #{e.message}"
        return record.customer_orders.to_a
      end
    end

    # Box: expand to customer_boxes, then their customer_orders
    if record.is_a?(Box) && record.respond_to?(:customer_boxes)
      return record.customer_boxes.flat_map do |customer_box|
        begin
          customer_box.customer_orders.includes(orderables: :variation).to_a
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
end