class CustomerBox < Box
  belongs_to :box, foreign_key: :box_id
  belongs_to :customer_order
  has_one :customer_email
  has_one :customer, through: :customer_order, foreign_key: :box_id
  has_one :address, through: :customer_order
  has_many :orderables, through: :customer_order

  def orderable_notes_map
    orderables.map(&:notes).compact
  end

  def order_preferences_map
    customer_order.preferences.map(&:name).compact
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
