class Box < ApplicationRecord
  belongs_to :box, foreign_key: :box_id, optional: true
  has_many :customer_boxes, foreign_key: :box_id, inverse_of: :box
  has_many :customer_orders, through: :customer_boxes, source: :customer_order
  has_many :box_variations, dependent: :destroy
  has_many :variations, through: :box_variations
  has_one :email
  has_rich_text :note

  # after_save :generate_customer_boxes

  def generate_customer_boxes
    subscribers = CustomerOrder.active.processed
    box_count = self.customer_boxes.size
    first_box = subscribers.where(last_box_date: nil)
    weekly_subscribers = subscribers.weekly.current_sub
    bimonthly_subscribers = subscribers.bimonthly.where("last_box_date <= ?", self.date - 2.weeks).current_sub
    monthly_subscribers = subscribers.monthly.where("last_box_date <= ?", self.date - 3.weeks).current_sub
    active_subscribers = weekly_subscribers + bimonthly_subscribers + monthly_subscribers + first_box
    current_boxes = self.customer_orders.map { |x| x['id'] }
    active_subscribers = active_subscribers.map { |x| x['id'] }
    customer_orders = active_subscribers - current_boxes
    customer_orders.each do |customer|
      subscriber = CustomerOrder.find(customer) 
      box = self.customer_boxes.create(date: self.date, customer_order: subscriber)
      subscriber.update(last_box_date: self.date)
    end
    'add variations from parent box that matches customer preferences'
  end

  def send_email
    self.customer_boxes.each do |box|
      next box if box.email_sent?
      customer_order = box.customer_order
      CustomerOrderMailer.box_email(self, customer_order, box).deliver
      box.update(email_sent: true, email_sent_date: Time.zone.now )
    end
  end


end
