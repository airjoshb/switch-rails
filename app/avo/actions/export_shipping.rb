require 'csv'

class ExportShipping < Avo::BaseAction
  self.name = "Export Shipping CSV"
  self.may_download_file = true

  # optional UI toggles you can expose later
  field :include_headers, as: :boolean, name: "Include headers", default: true

  # Example shipping CSV header (matches your example)
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

    csv = CSV.generate(headers: true) do |csv|
      csv << SHIPPING_HEADERS if fields[:include_headers] != false

      models.each do |record|
        # Determine customer (record may be a CustomerOrder or a Customer)
        customer = find_customer_from_record(record)

        email = safe_string(customer&.email || record.try(:email))
        name  = safe_string(customer&.name || record.try(:name))

        # Attempt to find the best address:
        # 1) record.address
        # 2) customer.addresses.first
        # 3) record.address_attributes (fallback)
        address = find_address_from_record_or_customer(record, customer)

        company = ""
        addr1   = safe_string(address_try(address, :street_1) || address_try(address, :street) || address_try(address, :line1) || address_try(address, :full_address))
        addr2   = safe_string(address_try(address, :street_2) || address_try(address, :line2))
        city    = safe_string(address_try(address, :city))
        state   = safe_string(address_try(address, :state))
        zip     = safe_string(address_try(address, :postal) || address_try(address, :zipcode) || address_try(address, :postal_code))
        country = "USA"

        # Order id - prefer guid if present
        order_id = record.customer_orders.first.try(:guid) || record.try(:id) || ""

        # Order items - join variation names (works for CustomerOrder models)
        items = ""
        if record.respond_to?(:orderables)
          names = record.orderables.map { |o| o.variation&.name || o.try(:name) }.compact
          items = names.join(" | ")
        elsif record.respond_to?(:variations)
          names = record.variations.map(&:name).compact
          items = names.join(" | ")
        end

        # Measurements - default blank. Replace with real attributes if you store them.
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

    download csv, "#{resource.plural_name.parameterize(separator: '_')}_shipping.csv"
  end

  private

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

  def find_address_from_record_or_customer(record, customer)
    # Common patterns in app:
    # - record.address (CustomerOrder#address or CustomerBox#address)
    # - customer.addresses.first
    # - record.address_attributes hash
    customer_order = CustomerOrder.find_by(id: record.customer_orders.first.id ) if record.respond_to?(:customer_orders) && record.customer_orders.any?
    address = Address.find_by(id: customer_order.address.id ) if record.respond_to?(:customer_order_id) && customer_order&.address
    return address if address
    return record.address if record.respond_to?(:address) && record.address.present?
    return record.try(:address_attributes) if record.respond_to?(:address_attributes) && record.address_attributes.present?
    return record.addresses.first if customer && customer.respond_to?(:addresses) && customer.addresses.any?
    nil
  end

  def find_customer_from_record(record)
    # record might be a CustomerOrder, CustomerEmail, or Customer directly
    return record if record.is_a?(Customer)
    if record.respond_to?(:customer) && record.customer.present?
      return record.customer
    end
    # some records may have a customer_id column:
    if record.respond_to?(:customer_order) && record.customer_orders.first.present?
      return Customer.find_by(id: record.customer_orders.first.customer.id)
    end
    nil
  end

  def get_columns_from_fields(fields)
    fields.select { |key, value| value }.keys
  end
end