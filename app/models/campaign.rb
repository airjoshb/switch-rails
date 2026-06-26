class Campaign < ApplicationRecord
  has_and_belongs_to_many :emails, inverse_of: :campaigns
  has_and_belongs_to_many :customers, inverse_of: :campaigns

  def send_email
    self.emails.last.generate_customer_emails(self)       
  end

  def add_all_fans
    fan_customers = Customer.where(fan: true)
    missing_fans = fan_customers.where.not(id: self.customer_ids)
    self.customers << missing_fans if missing_fans.any?
  end

end
