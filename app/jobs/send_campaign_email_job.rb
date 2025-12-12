class SendCampaignEmailJob < ApplicationJob
  queue_as :default

  def perform(customer_id, email_id)
    customer = Customer.find_by(id: customer_id)
    email = Email.find_by(id: email_id)
    return unless customer && email && customer.emailable?

    customer_email = email.customer_emails.find_by(customer_id: customer.id)
    return if customer_email&.email_sent?

    CampaignCustomerMailer.customer_email(customer, email).deliver_now
    email.customer_emails.create!(email_sent: true, sent_date: Time.zone.now, customer: customer)
  end
end
