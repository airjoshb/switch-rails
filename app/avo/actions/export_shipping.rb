require 'csv'

class ExportShipping < Avo::BaseAction
  self.name = "Export Shipping CSV"
  self.may_download_file = true

  field :include_headers, as: :boolean, name: "Include headers", default: true

  SHIPPING_HEADERS = [
    "Email",
    "Name",
    "Company",
    "Address",
    "Address Line 2",
    "City",
    "State",
    "Zipcode",
    "Country",
    "Order ID",
    "Order Items",
    "Pounds",
    "Length",
    "Width",
    "Height"
  ].freeze

  def handle(models:, resource:, fields:, **)
    return error("No records selected") if models.blank?

    csv_data = CSV.generate(headers: true) do |csv|
      csv << SHIPPING_HEADERS if fields[:include_headers] != false

      models.each do |record|
        # Expand record into shippable orders (Box -> customer_boxes -> customer_orders, CustomerOrder -> self)
        orders = extract_orders_from_record(record)

        orders.each do |order|
          customer = order.customer
          address  = order.address

          email = safe_string(customer&.email)
          name  = safe_string(customer&.name)
          company = ""

          addr1 = safe_string(
            address_try(address, :street_1) || 
            address_try(address, :street) || 
            address_try(address, :line1) || 
            address_try(address, :full_address)
          )
          addr2 = safe_string(address_try(address, :street_2) || address_try(address, :line2))
          city  = safe_string(address_try(address, :city))
          state = safe_string(address_try(address, :state))
          zip   = safe_string(
            address_try(address, :postal) || 
            address_try(address, :zipcode) || 
            address_try(address, :postal_code)
          )
          country = "USA"

          order_id = order.try(:guid) || order.id.to_s

          # Collect variation names from orderables
          items = if order.respond_to?(:orderables) && order.orderables.any?
                    order.orderables.map { |o| o.variation&.name }.compact.join(" | ")
                  else
                    ""
                  end

          pounds = "2"
          length = "12"
          width  = "8"
          height = "6"

          csv << [
            email,
            name,
            company,
            addr1,
            addr2,
            city,
            state,
            zip,
            country,
            order_id,
            items,
            pounds,
            length,
            width,
            height
          ]
        end
      end
    end

    download csv_data, "#{resource.plural_name.parameterize(separator: '_')}_shipping.csv"
  end

  private

  def extract_orders_from_record(record)
    # Box: expand to customer_boxes, then their customer_orders
    if record.is_a?(Box) && record.respond_to?(:customer_boxes)
      return record.customer_boxes.flat_map do |customer_box|
        customer_box.customer_orders.to_a
      end.compact
    end

    # CustomerBox: extract its customer_orders
    if record.class.name == "CustomerBox" && record.respond_to?(:customer_orders)
      return record.customer_orders.to_a
    end

    # CustomerOrder: return as-is
    if record.is_a?(CustomerOrder)
      return [record]
    end

    # Fallback: treat as a single order
    [record]
  end

  def safe_string(val)
    return "" if val.nil?
    val.to_s.strip
  end

  def address_try(address, method)
    return nil unless address
    if address.respond_to?(method)
      address.public_send(method)
    elsif address.is_a?(Hash)
      address[method.to_s] || address[method.to_sym]
    end
  end
end