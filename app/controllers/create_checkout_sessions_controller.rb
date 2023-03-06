class CreateCheckoutSessionsController < ApplicationController
  skip_before_action :authenticate
  skip_before_action :verify_authenticity_token

  # This example sets up an endpoint using the Sinatra framework.
  # Watch this video to get started: https://youtu.be/8aA9Enb8NVc.
  require 'stripe'

  # Set your secret key. Remember to switch to your live secret key in production.
  # See your keys here: https://dashboard.stripe.com/apikeys
  Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY')
 
  def create
    cart = Cart.find(params[:cart_id])
    prices = cart.variations.group(:id).pluck('stripe_id, count(stripe_id)')
    adjustable = Hash(enabled: true, minimum: 1, maximum: 10)
    line_items = prices.map{|e| {price:  e.first, quantity: e.last, adjustable_quantity: adjustable} }
    mode = cart.variations.recurring.any? ? "subscription" : "payment"
    customer_creation = "if_required" unless mode == "subscription"
    checkout_session = Stripe::Checkout::Session.create({
      line_items: line_items,
      mode: mode,
      customer_creation: customer_creation,
      allow_promotion_codes: true,
      phone_number_collection: {
        enabled: true
      },
      shipping_address_collection: {
        allowed_countries: ['US'],
      },
      success_url: cart_success_url,
      cancel_url:  cart_cancel_url,
    })
    order = CustomerOrder.create(stripe_checkout_id: checkout_session.id)
    order.orderables << cart.orderables
    reset_session
    redirect_to checkout_session.url, allow_other_host: true, status: 303
  end
   
  def webhook
    event = nil
    endpoint_secret = ENV.fetch('ENDPOINT_SECRET')

    # Verify webhook signature and extract the event
    # See https://stripe.com/docs/webhooks/signatures for more information.
    begin
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      payload = request.body.read
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      # Invalid payload
      return status 400
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      return status 400
    end
    
    case event['type']
    when 'customer.created'
      checkout_session = event['data']['object']

      create_customer(checkout_session)
    when 'checkout.session.completed'
      checkout_session = event['data']['object']

      # Save an order in your database, marked as 'awaiting payment'
      create_order(checkout_session)

      # Check if the order is already paid (for example, from a card payment)
      #
      # A delayed notification payment will have an `unpaid` status, as
      # you're still waiting for funds to be transferred from the customer's
      # account.
      if checkout_session.payment_status == 'paid'
        process_order(checkout_session)
      end
    when 'checkout.session.async_payment_succeeded'
      checkout_session = event['data']['object']

      # Fulfill the purchase...
      process_order(checkout_session)
    when 'checkout.session.async_payment_failed'
      session = event['data']['object']

      # Send an email to the customer asking them to retry their order
      email_customer_about_failed_payment(checkout_session)
    else
      puts "Unhandled event type: #{event.type}"
    end
    render json: { state: "processed" }, status: :ok
    # status 200
  end

  private
  def create_customer(checkout_session)
    search = Stripe::Customer.search({query: "email:\'#{checkout_session.email}\'"}).first
    customer ||= Stripe::Customer.retrieve(search.id)
    if customer.nil?
      customer = Customer.create(stripe_id: checkout_session.id, email: checkout_session.email, phone: checkout_session.phone, name: checkout_session.name)
    end
    puts "Created #{customer.name} for #{checkout_session.inspect}"
  end

  def process_order(checkout_session)
    order = CustomerOrder.find_by_stripe_checkout_id(checkout_session.id)
    order.processed!
    puts "Fulfilling ##{order.guid} for #{order.orderables.inspect}"
  end

  def create_order(checkout_session)
    begin
      order = CustomerOrder.find_by_stripe_checkout_id(checkout_session.id)
      payment = Stripe::PaymentIntent.retrieve(checkout_session.payment_intent)
      payment_method = Stripe::PaymentMethod.retrieve(payment.payment_method)
      address_check = payment_method.card.checks.address_line1_check == "pass" && payment_method.card.checks.address_postal_code_check == "pass" ? true : false
      address = Address.create(
        street_1: checkout_session.shipping_details.address.line1, 
        street_2: checkout_session.shipping_details.address.line2, 
        city: checkout_session.shipping_details.address.city, 
        state: checkout_session.shipping_details.address.state, 
        postal: checkout_session.shipping_details.address.postal_code, 
        address_check: address_check, 
        customer_order: order)
      pass_check = payment_method.card.checks.cvc_check == "pass" ? true : false
      method = PaymentMethod.create(
        stripe_id: payment_method.id, 
        card_type: payment_method.card.brand, 
        cvc_check: pass_check, 
        last_4: payment_method.card.last4,
        customer_order: order)
      order.update(description: payment.description, stripe_id: checkout_session.payment_intent, amount: checkout_session.amount_total)
      customer = Customer.where(email: checkout_session.customer_details.email).first_or_create
      customer.update(phone: checkout_session.customer_details.phone, name: checkout_session.customer_details.name)
      customer.customer_orders << order
    end
    puts "Created order ##{order.guid} for #{checkout_session.inspect}"
  end
  
  def email_customer_about_failed_payment(checkout_session)
    order = Order.find_by_stripe_id(checkout_session.payment_intent)
    order.failed!
    puts "Emailing customer about payment failure for: #{checkout_session.inspect}"
  end

end