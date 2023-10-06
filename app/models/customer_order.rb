class CustomerOrder < ApplicationRecord
  belongs_to :customer, optional: true, dependent: :destroy
  has_many :orderables, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :variations, through: :orderables
  has_many :customer_boxes
  has_one :address, dependent: :destroy
  has_one :payment_method, dependent: :destroy

  enum order_status: {pending: 'pending', processed: 'processed', failed: 'failed', fulfilled: 'fulfilled', refunded: 'refunded'}
  SUBSCRIPTION_STATUS = %i[active canceled paused].freeze
  validates_uniqueness_of :guid

  scope :monthly, -> { joins(:variations).where(variations: { interval: :month })}
  scope :weekly, -> { joins(:variations).where('variations.interval = ? AND variations.interval_count = ?', 'week', 1 ) }
  scope :bimonthly, -> { joins(:variations).where('variations.interval = ? AND interval_count = ?', 'week', 2 ) }
  scope :active, -> { where(subscription_status: :active).where.not(subscription_id: nil)}
  scope :current_sub, -> { joins(:orderables).where(orderables: { current: true }).distinct}
  scope :processed, -> { where(order_status: :processed )}


  after_initialize  :populate_guid, if: Proc.new { |p| p.guid.blank? }
  after_save :deliver_order_confirmation, if: Proc.new { saved_change_to_order_status?(from: 'pending', to: 'processed') }
  
  def deliver_order_confirmation
    return if self.receipt_sent
    CustomerOrderMailer.receipt_email(self).deliver
    self.update(receipt_sent: true, receipt_sent_date: Time.zone.now )
  end

  def fetch_invoices
    if self.subscription_id.present?
      subscription = Stripe::Subscription.retrieve(self.subscription_id)
      invoices = Stripe::Invoice.list(subscription: subscription)
    else
      invoices = Stripe::Invoice.search(query: 'customer:'"'#{self.customer.stripe_id}'", limit:'100')
    end
    for invoice in invoices
      time_start = Time.at(invoice.period_start.to_i)
      time_end = Time.at(invoice.period_end.to_i)
      new_invoice = self.invoices.find_or_create_by(invoice_id: invoice.id)
      new_invoice.update(subscription_id: invoice.subscription, period_start: time_start, 
        period_end: time_end, amount_due: invoice.amount_due, invoice_status: invoice.status, amount_paid: invoice.amount_paid 
      )
      if new_invoice.paid?
        new_invoice.pay_invoice
      end
    end
  end

  def update_subscription_status
    stripe_subscription = Stripe::Subscription.retrieve(self.subscription_id)
    price = stripe_subscription.items.first.price.id
    unless self.variations.exists?(stripe_id: price)
      variation = Variation.find_by_stripe_id(price)
      self.orderables.last.update(current: false)
      self.orderables.create(variation: variation, quantity: stripe_subscription.items.first.quantity, cart: self.orderables.first.cart, current: true)
    end
    self.update(subscription_status: stripe_subscription.status)
    puts "Updated Subscription"
  end

  private

  def populate_guid
    if new_record?
      while !valid? || self.guid.nil?
        self.guid = SecureRandom.random_number(1_000_000_000).to_s(36)
      end
    end
  end

end
