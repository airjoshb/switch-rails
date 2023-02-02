class CustomerOrderMailer < ApplicationMailer
  helper :application
  layout 'mailer'
  
  def receipt_email(customer_order)
    @customer = customer_order.customer
    @order = customer_order
    mail(:to => @customer.email, :subject => "Your Switch Bakery order is in process!")
  end
end
