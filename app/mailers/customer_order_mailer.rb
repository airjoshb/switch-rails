class CustomerOrderMailer < ApplicationMailer
  helper :application
  
  def receipt_email(customer_order)
    @customer = customer_order.customer
    @order = customer_order
    mail(:to => @customer.email, :subject => "Your Switch Bakery order is in process!")
  end
end
