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
    prices = cart.orderables.joins(:variation).pluck('variations.stripe_id', 'quantity')
    # prices = cart.variations.group(:id).pluck('stripe_id, count(stripe_id)')
    adjustable = Hash(enabled: true, minimum: 1, maximum: 10)
    line_items = prices.map{|e| {price:  e.first, quantity: e.last, adjustable_quantity: adjustable} }
    mode = cart.variations.recurring.any? ? "subscription" : "payment"
    customer_creation = "if_required" unless mode == "subscription"
    if params[:shipping] == 'shr_1NR39pLHQPVTKPLFaiYcBs0M'
      shipping = [{label: 'N/A', value: 'ship'}]
    else
      shipping = [{label: 'Tuesday Market (Monterey)', value: 'tuesday'}, {label: 'Thursday Market (Carmel by the Sea)', value: 'thursday'}]
    end
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
      shipping_options: [
        shipping_rate: mode == "subscription" ? nil : params[:shipping],
      ],
      consent_collection: {
        promotions: 'auto',
      },
      custom_fields: [
        {
          key: 'pickup',
          label: {type: 'custom', custom: 'Pickup Location'},
          optional: true,
          type: 'dropdown',
          dropdown: {
            options: 
              shipping
          },
        },
      ],
      success_url: cart_success_url,
      cancel_url:  cart_cancel_url,
    })
    if mode == "subscription"
      status = "active" 
    else 
      status = nil
    end
    order = CustomerOrder.create(stripe_checkout_id: checkout_session.id, subscription_status: status)
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
    when 'invoice.created'
      invoice = event['data']['object']
      create_invoice(invoice)
    when 'invoice.finalized' 
    when 'invoice.updated'
    when 'invoice.upcoming'
    when 'customer.subscription.created'
    when 'customer.subscription.updated'
      subscription = event['data']['object']
      update_subscription_status(subscription.id)
    when 'invoice.paid'
      # invoice = event['data']['object']
      # pay_invoice(invoice)
    when 'invoice.payment_succeeded'
      invoice = event['data']['object']
      pay_invoice(invoice.id)
    when 'payment_intent.succeeded'
    when 'payment_intent.created'
    when 'customer.created'
      customer = event['data']['object']

      create_customer(customer)
    when  'customer.updated'
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
    when 'charge.succeeded'
    when 'payment_method.attached'
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
  def create_customer(customer)
    stripe_customer = Stripe::Customer.retrieve(customer.id)
    customer = Customer.create_with(email: stripe_customer.email, phone: stripe_customer.phone, name: stripe_customer.name).find_or_create_by(stripe_id: stripe_customer.id)
    puts "Created #{customer.name} for #{stripe_customer.inspect}"
  end

  def update_customer(customer)
    stripe_customer = Stripe::Customer.retrieve(customer.id)
    customer = Customer.find_by_stripe_id(stripe_customer)
    customer.update(email: customer.email, phone: customer.phone, name: customer.name)
    puts "Updated #{customer.name} for #{stripe_customer.inspect}"
  end

  def create_payment_method(payment, order)
    payment_method = Stripe::PaymentMethod.retrieve(payment)
    pass_check = payment_method.card.checks.cvc_check == "pass" ? true : false
    payment = PaymentMethod.create(stripe_id: payment_method.id,
      card_type: payment_method.card.brand, 
      cvc_check: pass_check, 
      last_4: payment_method.card.last4,
      customer_order: order
    )
    puts "Created Payment Method for #{payment.inspect}"
  end

  def create_address(checkout_session, order)
    address = Address.create(street_1: checkout_session.shipping_details.address.line1,
      street_2: checkout_session.shipping_details.address.line2, 
      city: checkout_session.shipping_details.address.city, 
      state: checkout_session.shipping_details.address.state, 
      postal: checkout_session.shipping_details.address.postal_code,
      customer_order: order
    )
    puts "Created Address for #{checkout_session.inspect}"
  end

  def process_order(checkout_session)
    order = CustomerOrder.find_by_stripe_checkout_id(checkout_session.id)
    pay_invoice(checkout_session.invoice) if checkout_session.mode == "subscription"
    order.processed!
    puts "Processed ##{order.guid} for #{order.orderables.inspect}"
  end

  def create_order(checkout_session)
    begin
      order = CustomerOrder.find_by_stripe_checkout_id(checkout_session.id)
      consent = checkout_session.consent.promotions == "opt_in" ? true : false
      if checkout_session.mode == "subscription"
        invoice = Stripe::Invoice.retrieve(checkout_session.invoice)
        intent = Stripe::PaymentIntent.retrieve(invoice.payment_intent) 
      else
        intent = Stripe::PaymentIntent.retrieve(checkout_session.payment_intent)
      end
      create_address(checkout_session, order)
      create_payment_method(intent.payment_method, order)
      order.update(stripe_id: checkout_session.id, amount: checkout_session.amount_total, fulfillment_method: checkout_session.custom_fields.first.dropdown.value, subscription_id: checkout_session.subscription )
      customer = Customer.where(email: checkout_session.customer_details.email).first_or_create
      customer.update(phone: checkout_session.customer_details.phone, name: checkout_session.customer_details.name, stripe_id: checkout_session.customer, promotion_consent: consent)
      customer.customer_orders << order
      if checkout_session.mode == "subscription"
        create_invoice(invoice)
      end
    end
    puts "Created order ##{order.guid} for #{checkout_session.inspect}"
  end

  def create_invoice(invoice)
    if invoice.subscription.present?
      customer_order = CustomerOrder.find_by_subscription_id(invoice.subscription)
    else
      stripe_customer = Stripe::Customer.retrieve(invoice.customer)
      customer = Customer.create_with(phone: stripe_customer.phone, name: stripe_customer.name).find_or_create_by(stripe_id: stripe_customer.id)
      intent = Stripe::PaymentIntent.retrieve(invoice.payment_intent) 
      orderables = []
      cart = Cart.create
      customer_order = customer.customer_orders.create
      for line in invoice.lines
        variation = Variation.find_by_stripe_id(line.price.id)
        orderable = Orderable.create(variation: variation, quantity: line.quantity, cart: cart, current: true)
        orderables << orderable
      end
      customer_order.orderables << orderables
      customer_order.address.create(city: invoice.customer_address.city, 
        street_2: invoice.customer_address.line_2, 
        street_1: invoice.customer_address.line_1,
        state: invoice.customer_address.state,
        postal: invoice.customer_address.postal_code
      )
      create_payment_method(intent.payment_method, customer_order)
    end
    new_invoice = Invoice.find_or_create_by(invoice_id: invoice.id)
    time_start = Time.at(invoice.period_start.to_i)
    time_end = Time.at(invoice.period_end.to_i)
    new_invoice.update(subscription_id: invoice.subscription, period_start: time_start, period_end: time_end,
      amount_due: invoice.amount_due, invoice_status: invoice.status
    )
    if customer_order.present?
      customer_order.invoices << new_invoice
    end
    puts "Created invoice ##{new_invoice.id}"
  end

  def update_subscription_status(subscription)
    order = CustomerOrder.find_by_subscription_id(subscription)
    return unless order.present?
    stripe_subscription = Stripe::Subscription.retrieve(subscription)
    price = stripe_subscription.items.first.price.id
    unless order.variations.exists?(stripe_id: price)
      variation = Variation.find_by_stripe_id(price)
      order.orderables.last.update(current: false)
      order.orderables.create(variation: variation, quantity: stripe_subscription.items.first.quantity, cart: order.orderables.first.cart, current: true)
    end
    order.update(subscription_status: stripe_subscription.status)
    puts "Updated Subscription"
  end

  def pay_invoice(invoice)
    stripe_invoice = Stripe::Invoice.retrieve(invoice)
    get_invoice = Invoice.find_by_invoice_id(stripe_invoice.id)
    get_invoice.update(amount_paid: stripe_invoice.amount_paid, paid: true)
    get_invoice.paid!
  end

  def email_customer_about_failed_payment(checkout_session)
    order = Order.find_by_stripe_id(checkout_session.payment_intent)
    order.failed!
    puts "Emailing customer about payment failure for: #{checkout_session.inspect}"
  end

end