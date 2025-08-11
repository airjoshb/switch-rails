class CampaignCustomerMailer < ApplicationMailer
  helper :application
  layout 'mailer'
  
  def customer_email(customer, email)
    attachments.inline['switch-bakery-gluten-free-bread.png'] = File.read(Rails.root.join('app/assets/images/switch-bakery-gluten-free-bread.png'))
    @customer = customer
    @email = email
    mail(:to => @customer.email, :subject => email.subject)
  end
end
