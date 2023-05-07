class CustomerOrder < ApplicationRecord
  belongs_to :customer, optional: true, dependent: :destroy
  has_many :orderables, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_one :address, dependent: :destroy
  has_one :payment_method, dependent: :destroy

  enum order_status: {pending: 'pending', processed: 'processed', failed: 'failed', fulfilled: 'fulfilled', refunded: 'refunded'}

  validates_uniqueness_of :guid

  after_initialize  :populate_guid, if: Proc.new { |p| p.guid.blank? }
  after_save :deliver_order_confirmation, if: Proc.new { saved_change_to_order_status?(from: 'pending', to: 'processed') }
  
  def deliver_order_confirmation
    return if self.receipt_sent
    CustomerOrderMailer.receipt_email(self).deliver
    self.update(receipt_sent: true, receipt_sent_date: Time.zone.now )
  end

  def fetch_invoices
    subscription = Stripe::Subscription.retrieve(self.subscription_id)
    invoices = Stripe::Invoice.list(subscription: subscription)
    for invoice in invoices
      new_invoice = self.invoices.find_or_create_by(invoice_id: invoice.id)
      new_invoice.update(subscription_id: invoice.subscription, period_start: invoice.period_start, 
        period_end: invoice.period_end, amount_due: invoice.amount_due, invoice_status: invoice.status, amount_paid: invoice.amount_paid 
      )
      if new_invoice.paid?
        new_invoice.pay_invoice
      end
    end
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
