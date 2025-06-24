class Campaign < ApplicationRecord
  has_and_belongs_to_many :emails
  has_and_belongs_to_many :customers

  def send_email
    self.emails.each do |email|
      next email if self.customers.length == email.customers.length
      email.generate_customer_emails(self)       
    end
  end

end
