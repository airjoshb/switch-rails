class ExportPdf < Avo::BaseAction
  self.name = "Export PDF"
  self.may_download_file = true

  def handle(models:, resource:, **)
    require 'prawn'

    pdf = Prawn::Document.new

    models.each do |order|
      pdf.text "Customer Name: #{order.customer&.name || 'N/A'}", style: :bold
      pdf.text "Fulfillment Method: #{order.fulfillment_method || 'N/A'}"
      pdf.text "Address: #{order.address&.full_address || 'N/A'}"
      pdf.move_down 5

      pdf.text "Orderables:", style: :bold
      if order.orderables.any?
        data = [["Variation Name"]]
        data += order.orderables.map { |o| [o.variation&.name || 'N/A'] }
        pdf.table(data, header: true, width: 300)
      else
        pdf.text "No orderables."
      end

      pdf.move_down 20
      pdf.stroke_horizontal_rule
      pdf.move_down 20
    end

    send_data pdf.render, filename: "customer_orders.pdf", type: "application/pdf"
  end
end