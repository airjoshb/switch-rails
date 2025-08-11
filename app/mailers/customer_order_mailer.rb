class CustomerOrderMailer < ApplicationMailer
  helper :application
  layout 'mailer'
  
  def receipt_email(customer_order)
    @customer = customer_order.customer
    @order = customer_order
    mail(:to => @customer.email, :subject => "Your Switch Bakery order is in process!")
  end

  def box_email(box, customer_order, customer_box)
    @customer = customer_order.customer
    @box = box
    @customer_box = customer_box
    mail(:to => @customer.email, :cc => "amanda@switchbakery.com", :subject => @box.email.subject)
  end
end
