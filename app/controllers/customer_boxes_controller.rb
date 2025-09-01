class CustomerBoxesController < ApplicationController
  require 'stripe'

  # Set your secret key. Remember to switch to your live secret key in production.
  # See your keys here: https://dashboard.stripe.com/apikeys
  Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY')
  def show
    @customer_box = CustomerBox.find(params[:id])
    # if params[:token].present? && @customer_box.access_token == params[:token]
    #   @add_ons = @customer_box.box.variations
    #   order_id = session["customer_box_#{@customer_box.id}_order_id"]
    #   @order = CustomerOrder.find_by(id: order_id) ||CustomerOrder.new
    #   render layout: "customer"    
    # else
    #   redirect_to root_path, alert: "Access denied."
    # end
    @customer = @customer_box.customer
    @add_ons = @customer_box.box.variations
    order_id = session["customer_box_#{@customer_box.id}_order_id"]
    @order = CustomerOrder.find_by(id: order_id) ||CustomerOrder.new
    render layout: "customer" 
  end

  def update_add_ons
    @customer_box = CustomerBox.find(params[:id])

    # Find or create the order for this session/customer_box
    order_id = session["customer_box_#{@customer_box.id}_order_id"]
    @order = @customer_box.customer_orders.find_by(id: order_id)

    unless @order
      @order = CustomerOrder.create(customer: @customer_box.customer)
      @customer_box.customer_orders << @order
      session["customer_box_#{@customer_box.id}_order_id"] = @order.id
    end

    variation_id = params[:variation_id]
    quantity = params[:quantity].to_i

    if variation_id.present? && quantity > 0
      variation = Variation.find(variation_id)
      orderable = @order.orderables.find_or_initialize_by(variation: variation)
      orderable.quantity = (orderable.quantity || 0) + quantity
      orderable.save!
      @order.save!

      respond_to do |format|
        # format.turbo_stream do
        #   Rails.logger.info "Rendering turbo_stream for order: #{@order.id}, orderables count: #{@order.orderables.count}"
          # render turbo_stream: turbo_stream.replace(
          #   "customer_box_summary",
          #   partial: "customer_boxes/summary",
          #   locals: { order: @order }
          # )
        # end
        # format.turbo_stream do
        #   render turbo_stream: turbo_stream.replace('customer_box_summary', partial: 'summary', locals: { order: @order })
        # end
        format.html { redirect_to customer_box_path(@customer_box), notice: "Item added!" }
      end
    end
  end

  def remove
    orderable = Orderable.find_by(id: params[:id])
    order = orderable.customer_order
    orderable.destroy

    respond_to do |format|
      format.turbo_stream do
        Rails.logger.info "Rendering turbo_stream for order: #{order.id}, orderables count: #{order.orderables.count}"
        render turbo_stream: turbo_stream.replace(
          "customer_box_summary",
          partial: "customer_boxes/summary",
          locals: { order: order }
        )
      end
      format.html { redirect_to customer_box_path(order.customer_box) }
    end
  end

  def complete_order
    @customer_box = CustomerBox.find(params[:id])
    order_id = session["customer_box_#{@customer_box.id}_order_id"]
    @order = @customer_box.customer_orders.find_by(id: order_id)

    if @order.nil? || @order.orderables.empty?
      redirect_to customer_box_path(@customer_box), alert: "No items to order."
      return
    end

    customer = @order.customer
    stripe_customer = Stripe::Customer.retrieve(customer.stripe_id)
    payment_methods = Stripe::Customer.list_payment_methods(
      stripe_customer.id,
      {limit: 3},
    )
    payment_method = Stripe::PaymentMethod.retrieve(payment_methods.first.id)
    switch_payment_method = PaymentMethod.find_by(stripe_id: payment_method.id)
    # Create Stripe payment intent or charge
    amount = @order.orderables.sum { |o| o.quantity * o.variation.amount }
    variation_names = @order.orderables.map { |o| o.variation.name }.join(", ")
    begin
      charge = Stripe::PaymentIntent.create(
        amount: amount.to_i, # Stripe expects cents
        currency: "usd",
        customer: stripe_customer,
        payment_method: payment_method, # adjust as needed
        off_session: true,
        confirm: true,
        description: "Order added to your box with: #{variation_names}"
      )
      @order.update(order_status: "processed", stripe_id: charge.id, amount: amount, payment_method: switch_payment_method)
      @order.deliver_order_confirmation
      redirect_to customer_box_path(@customer_box), notice: "Order confirmed and charged!"
    rescue Stripe::CardError => e
      redirect_to customer_box_path(@customer_box), alert: "Payment failed: #{e.message}"
    end
  end

  private

  def order_params
    params.require(:customer_order).permit(orderables_attributes: [:variation_id, :quantity])
  end
end
