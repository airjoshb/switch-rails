class CustomerBox < Box
  belongs_to :boxable
  belongs_to :customer_order

  def set_dates
    'inherit date from parent box
    set to date of last box from customer order or date from box'
  end

end
