class CustomerOrdersController < ApplicationController

  def create
    @customer_order = CustomerOrder.new(customer_order_params)
    
    if @customer_order.save
      @customer_order.deliver_order_confirmation
    end
  end

  private

  def customer_order_params
    params.require(:customer_order).permit(:guid, :stripe_id, :description, :amount, :order_status, :stripe_checkout_id, :receipt_sent, :receipt_sent_date, customer_attributes: [])
  end
end
