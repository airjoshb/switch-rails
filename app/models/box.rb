class Box < ApplicationRecord
  belongs_to :box, foreign_key: :box_id, optional: true
  has_many :customer_boxes, foreign_key: :box_id, inverse_of: :box
  has_and_belongs_to_many :customer_orders, join_table: :boxes_customer_orders, foreign_key: :box_id
  has_many :box_variations, dependent: :destroy
  has_many :variations, through: :box_variations
  has_one :email
  has_rich_text :note

  default_scope { order(created_at: :desc) }

  # after_save :generate_customer_boxes
  before_create :set_access_token

  def generate_customer_boxes
    subscribers = CustomerOrder.active.processed
    box_count = self.customer_boxes.size
    first_box = subscribers.where(last_box_date: nil).pluck(:id)
    weekly_subscribers = subscribers.weekly.current_sub.distinct.pluck(:id)
    bimonthly_subscribers = subscribers.bimonthly.where(last_box_date: ..self.date - 13.days).current_sub.distinct.pluck(:id)
    monthly_subscribers = subscribers.monthly.where(last_box_date: ..self.date - 4.weeks).current_sub.distinct.pluck(:id)
    
    # Combine and deduplicate
    active_subscriber_ids = (first_box_ids + weekly_ids + bimonthly_ids + monthly_ids).uniq

    # IDs of customer_orders already attached to this box
    current_box_order_ids = self.customer_orders.pluck(:id)

    # Orders that need to be added
    to_add_ids = active_subscriber_ids - current_box_order_ids

    return if to_add_ids.empty?
    
    # Create boxes and associate orders
    # Optionally wrap in transaction if you want atomic behavior
    ActiveRecord::Base.transaction do
      to_add_ids.each do |order_id|
        subscriber = CustomerOrder.find_by(id: order_id)
        next unless subscriber

        box = self.customer_boxes.create!(date: self.date)
        box.customer_orders << subscriber
        subscriber.update!(last_box_date: self.date)
      end
    end

    # Return something descriptive if you like
    "created #{to_add_ids.size} customer_boxes"
  end

  def send_email
    self.customer_boxes.each do |box|
      next box if box.email_sent?
      customer_order = box.customer_orders.first
      CustomerOrderMailer.box_email(self, customer_order, box).deliver
      box.update(email_sent: true, email_sent_date: Time.zone.now )
    end
  end
  
  private

  def set_access_token
    self.access_token ||= SecureRandom.hex(20)
  end


end
