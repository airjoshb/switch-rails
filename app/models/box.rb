class Box < ApplicationRecord
  belongs_to :box, foreign_key: :box_id, optional: true
  has_many :customer_boxes, foreign_key: :box_id, inverse_of: :box
  has_many :customer_orders, through: :customer_boxes, source: :customer_order
  has_many :box_variations, dependent: :destroy
  has_many :variations, through: :box_variations
  has_many :emails
  has_rich_text :note

  # after_save :generate_customer_boxes

  def generate_customer_boxes
    subscribers = CustomerOrder.active.processed
    box_count = self.customer_boxes.size
    active_subscribers = []
    weekly_subscribers = subscribers.weekly.where('last_box_date > ?', self.date - 7.days).current_sub.distinct
    bimonthly_subscribers = subscribers.bimonthly.where(last_box_date: self.date - 2.weeks..self.date).current_sub.distinct
    monthly_subscribers = subscribers.monthly.where(last_box_date: self.date - 1.month..self.date).current_sub.distinct
    active_subscribers << weekly_subscribers + bimonthly_subscribers + monthly_subscribers
    existing_boxes = weekly_subscribers.size + bimonthly_subscribers.size + monthly_subscribers.size
    while box_count != existing_boxes
      active_subscribers.each do |subscribers|
        subscribers.each do |subscriber|
          box = self.customer_boxes.create(date: self.date, customer_order: subscriber)
          subscriber.update(last_box_date: self.date)
          box_count = box_count + 1
        end
      end
    end
    'add variations from parent box that matches customer preferences'
  end

  def send_email
    'send box email to all subscribers with customer boxes
    include notes from parent box & customer box'
  end

end
