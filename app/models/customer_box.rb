class CustomerBox < Box
  belongs_to :boxable, polymorphic: true
  belongs_to :customer_order
  has_one :customer_email
  
  def set_dates
    'inherit date from parent box
    set to date of last box from customer order or date from box'
  end

  def add_ons
    'get draft invoice and add line items
    or, generate new charge with orderable on the order'
  end

end
