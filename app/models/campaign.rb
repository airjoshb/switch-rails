class Campaign < ApplicationRecord
  has_and_belongs_to_many :emails
  has_and_belongs_to_many :customers

  def send_email
    self.emails.last do |email|
      next email if self.customers.length == email.customers.length
      email.generate_customer_emails(self)       
    end
  end

  def add_all_fans
    fan_customers = Customer.where(fan: true)
    missing_fans = fan_customers.where.not(id: self.customer_ids)
    self.customers << missing_fans if missing_fans.any?
  end

end
