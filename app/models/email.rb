class Email < ApplicationRecord
  belongs_to :box, optional: true
  has_and_belongs_to_many :campaigns
  has_many :customer_emails
  has_many :customers, through: :customer_emails
  has_rich_text :body
  has_many_attached :trix_attachments

  def generate_customer_emails(campaign)
    campaign.customers.find_each do |customer|
      next unless customer.emailable?
      customer_email = self.customer_emails.find_by(customer_id: customer.id)
      next if customer_email&.email_sent?

      CampaignCustomerMailer.customer_email(customer, self).deliver
      self.customer_emails.create(email_sent: true, sent_date: Time.zone.now, customer: customer)
    end
  end
end
