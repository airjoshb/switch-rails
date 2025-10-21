class ExportPdf < Avo::BaseAction
  self.name = "Export PDF"
  self.may_download_file = true

  def handle(models:, resource:, **)
    require 'prawn'
    require 'prawn/table'

    pdf = Prawn::Document.new

    models.each do |order|
      pdf.text order.created_at.strftime("%B %d, %Y %l:%M %p")
      pdf.text "#{order.customer&.name || 'N/A'}", style: :bold
      pdf.text "#{order.address&.full_address || 'N/A'}"
      pdf.text "Fulfillment Method: #{order.fulfillment_method || 'N/A'}"
      pdf.move_down 5

      if order.orderables.any?
        data = [["Qty", "Item"]]
        data += order.orderables.map do |o|
          variation = o.variation
          name = variation&.name || "N/A"
          notes = o.notes || ""
          unit_qty = variation&.unit_quantity || ""
          item_label = unit_qty.present? ? "#{unit_qty} x #{name} #{notes}" : name
          [ o.quantity || "N/A", item_label ]
        end
        pdf.table(data, header: false, width: 300)
      else
        pdf.text "No orderables."
      end

      pdf.move_down 20
      pdf.stroke_horizontal_rule
      pdf.move_down 20
    end

    download pdf.render, "customer_orders.pdf"
  end
end