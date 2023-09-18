class Box < ApplicationRecord
  has_many :customer_boxes, as: :boxable
  has_many :customer_orders, through: :customer_boxes
  has_many :box_variations, dependent: :destroy
  has_many :variations, through: :box_variations
  has_many :emails
  has_rich_text :note

  after_save :generate_customer_boxes

  def generate_customer_boxes
    subscribers = CustomerOrder.active
    return if self.customer_boxes.count == subscribers.current.weekly.count + subscribers.current.bimonthly + subscribers.current.bimonthly
    subscribers.current.weekly.each do |subscriber|
      return unless subscriber.last_box_date < self.date - 7
      self.customer_boxes.create(date: self.date, customer_order: subscriber)
      subscriber.update(last_box_date: self.date)
    end
    subscribers.current.bimonthly.each do |subscriber|
      start_date= self.date - 2.weeks
      end_date= self.date
      return unless subscriber.last_box_date.between?(start_date, end_date)
      self.customer_boxes.create(date: self.date, customer_order: subscriber)
      subscriber.update(last_box_date: self.date)
    end
    subscribers.current.bimonthly.each do |subscriber|
      start_date= self.date - 1.month
      end_date= self.date
      return unless subscriber.last_box_date.between?(start_date, end_date)
      self.customer_boxes.create(date: self.date, customer_order: subscriber)
      subscriber.update(last_box_date: self.date)
    end
    'add variations from parent box that matches customer preferences'
  end

  def send_email
    'send box email to all subscribers with customer boxes
    include notes from parent box & customer box'
  end

end
