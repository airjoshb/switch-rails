class CampaignCustomerMailer < ApplicationMailer
  helper :application
  layout 'mailer'
  
  def customer_email(customer, email)
    @customer = customer
    @email = email
    mail(:to => @customer.email, :subject => email.subject)
  end
end
