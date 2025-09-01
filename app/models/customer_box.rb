class CustomerBox < Box
  belongs_to :box, foreign_key: :box_id
  has_and_belongs_to_many :customer_orders, join_table: :boxes_customer_orders, foreign_key: :box_id, inverse_of: :customer_boxes
  has_one :customer_email
  has_many :orderables, through: :customer_orders
  has_one :address, through: :customer_orders

  def customers
    customer_orders.includes(:customer).map(&:customer).uniq
  end

  def customer
    customers.first
  end

  def address
    customer_orders.includes(:address).map(&:address).compact.first&.full_address
  end

  def orderable_notes_map
    orderables.map(&:notes).compact
  end

  def order_preferences_map
    customer_orders.flat_map { |order| order.preferences.map(&:name) }.compact
  end

  def order_preferences
    order_preferences_map.join(", ")
  end

  def orderable_notes
    orderable_notes_map.join(", ")
  end
    
  def total
    orderables.sum(&:total)
  end
  def set_dates
    'inherit date from parent box
    set to date of last box from customer order or date from box'
  end

  def add_ons
    'get draft invoice and add line items
    or, generate new charge with orderable on the order'
  end

end
