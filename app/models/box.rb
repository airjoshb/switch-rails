class Box < ApplicationRecord
  belongs_to :box, foreign_key: :box_id, optional: true
  has_many :customer_boxes, foreign_key: :box_id, inverse_of: :box
  has_and_belongs_to_many :customer_orders, join_table: :boxes_customer_orders, foreign_key: :box_id
  has_many :box_variations, dependent: :destroy
  has_many :variations, through: :box_variations
  has_one :email
  has_rich_text :note

  # remove: default_scope { order(created_at: :desc) }
  # add:
  scope :recent, -> { order(date: :desc) }

  # after_save :generate_customer_boxes
  before_create :set_access_token

  def generate_customer_boxes
    subscribers = CustomerOrder.active.processed

    # First-time subscribers (never had a box)
    first_box_ids = subscribers.where(last_box_date: nil).pluck(:id)

    # Weekly: include only those whose last_box_date is at least 7 days before this box date
    weekly_ids = subscribers.weekly.current_sub
                            .where.not(last_box_date: nil)
                            .where('last_box_date <= ?', self.date - 7.days)
                            .pluck(:id)

    # Bimonthly: last_box_date at least 13 days before this box date
    bimonthly_ids = subscribers.bimonthly.current_sub
                                  .where('last_box_date <= ?', self.date - 13.days)
                                  .pluck(:id)

    # Monthly: last_box_date at least 4 weeks before this box date
    monthly_ids = subscribers.monthly.current_sub
                              .where('last_box_date <= ?', self.date - 4.weeks)
                              .pluck(:id)

    # Combine and dedupe
    active_subscriber_ids = (first_box_ids + weekly_ids + bimonthly_ids + monthly_ids).uniq

    # IDs of customer_orders already attached to this Box (any existing customer_box)
    current_box_order_ids = self.customer_orders.pluck(:id)

    # Orders that need to be added
    to_add_ids = active_subscriber_ids - current_box_order_ids
    return if to_add_ids.empty?

    ActiveRecord::Base.transaction do
      to_add_ids.each do |order_id|
        subscriber = CustomerOrder.find_by(id: order_id)
        next unless subscriber

        # Defensive: skip if this exact subscriber is already attached to a customer_box
        # for this Box and date (protects against race conditions or previous runs).
        next if self.customer_boxes
                  .joins(:customer_orders)
                  .where(date: self.date, customer_orders: { id: subscriber.id })
                  .exists?

        # Create a new CustomerBox for this subscriber and associate the order
        box = self.customer_boxes.create!(date: self.date)
        box.customer_orders << subscriber
        subscriber.update!(last_box_date: self.date)
      end
    end

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
