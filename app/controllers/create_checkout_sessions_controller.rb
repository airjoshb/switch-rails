class CreateCheckoutSessionsController < ApplicationController

  # This example sets up an endpoint using the Sinatra framework.
  # Watch this video to get started: https://youtu.be/8aA9Enb8NVc.
  require 'stripe'

  # Set your secret key. Remember to switch to your live secret key in production.
  # See your keys here: https://dashboard.stripe.com/apikeys
  Stripe.api_key = ENV.fetch('STRIPE_API_KEY')
  endpoint_secret = ENV.fetch('ENDPOINT_SECRET')

  def create
    cart = Cart.find(params[:cart_id])
    prices = cart.variations.group(:id).pluck('stripe_id, count(stripe_id)')
    adjustable = Hash(enabled: true, minimum: 1, maximum: 10)
    line_items = prices.map{|e| {price:  e.first, quantity: e.last, adjustable_quantity: adjustable} }
    mode = cart.variations.recurring.any? ? "subscription" : "payment"
    checkout_session = Stripe::Checkout::Session.create({
      line_items: line_items,
      mode: mode,
      cancel_url: "/cart",
      allow_promotion_codes: true,
      phone_number_collection: {
        enabled: true
      },
      shipping_address_collection: {
        allowed_countries: ['US'],
      },
      success_url: 'http://localhost:3000/cart/success',
      cancel_url: 'http://localhost:3000/cart/cancel',
    })

    reset_session
    redirect_to checkout_session.url, allow_other_host: true, status: 303
  end
   
  def webhooks
    event = nil

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
        fulfill_order(checkout_session)
      end
    when 'checkout.session.async_payment_succeeded'
      checkout_session = event['data']['object']

      # Fulfill the purchase...
      fulfill_order(checkout_session)
    when 'checkout.session.async_payment_failed'
      session = event['data']['object']

      # Send an email to the customer asking them to retry their order
      email_customer_about_failed_payment(checkout_session)
    end

    status 200
  end

  def fulfill_order(line_items)
    # TODO: fill in with your own logic
    puts "Fulfilling order for #{line_items.inspect}"
  end

  def create_order(checkout_session)
    # TODO: fill in with your own logic
    puts "Creating order for #{checkout_session.inspect}"
  end
  
  def email_customer_about_failed_payment(checkout_session)
    # TODO: fill in with your own logic
    puts "Emailing customer about payment failure for: #{checkout_session.inspect}"
  end

end