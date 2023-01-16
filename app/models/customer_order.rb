class CustomerOrder < ApplicationRecord
  belongs_to :customer, optional: true, dependent: :destroy
  has_many :orderables, dependent: :destroy
  has_one :address, dependent: :destroy
  has_one :payment_method, dependent: :destroy

  enum order_status: {pending: 'pending', processed: 'processed', failed: 'failed', fulfilled: 'fulfilled', refunded: 'refunded'}

  validates_uniqueness_of :guid

  after_initialize  :populate_guid, if: Proc.new { |p| p.guid.blank? }
  # after_save :deliver_order_confirmation, if: Proc.new { |order| order.receipt_sent }
  
  def deliver_order_confirmation
    CustomerOrderMailer.receipt_email(self).deliver
    self.update(receipt_sent: true, receipt_sent_date: Time.zone.now )
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
