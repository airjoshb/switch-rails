class Box < ApplicationRecord
  has_many :customer_boxes, as: :boxable
  has_many :customer_orders, through: :customer_boxes
  has_many :box_variations, dependent: :destroy
  has_many :variations, through: :box_variations
  has_rich_text :note

  def generate_customer_boxes
    'get all active subscribers
    create boxes for only customers whose last box is within the timeframe for subscription interval
    add variations from parent box that matches customer preferences'
  end

  def send_email
    'send box email to all subscribers with customer boxes
    include notes from parent box & customer box'
  end

end
