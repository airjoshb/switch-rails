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
    if params[:notes].present?
      # Find the correct orderable in the cart (the one with recurring/unit_quantity > 1)
      bread_orderable = cart.orderables.find { |o| o.variation.recurring? && o.variation.unit_quantity > 1 }
      if bread_orderable
        bread_orderable.notes = params[:notes]
        bread_orderable.save
      end
    end
    # prices = cart.variations.group(:id).pluck('stripe_id, count(stripe_id)')
    adjustable = Hash(enabled: true, minimum: 1, maximum: 10)
    line_items = prices.map{|e| {price:  e.first, quantity: e.last, adjustable_quantity: adjustable} }
    mode = cart.variations.recurring.any? ? "subscription" : "payment"
    customer_creation = "if_required" unless mode == "subscription"
    shipping = [ {label: 'Scotts Valley @ Cruise Coffee', value: 'cruise'},{label: 'Wednesday Market (Santa Cruz)', value: 'wednesday'}, {label: 'Saturday Market (Santa Cruz)', value: 'saturday'} ]
    if mode == 'payment'
      shipping_rates = [
        {
          shipping_rate_data: {
            type: 'fixed_amount',
            fixed_amount: {
              amount: 0,
              currency: 'usd',
            },
            display_name: 'Pickup',
            delivery_estimate: {
              minimum: {
                unit: 'business_day',
                value: 1,
              },
              maximum: {
                unit: 'business_day',
                value: 2,
              },
            },
          },
        },
        {
          shipping_rate_data: {
            type: 'fixed_amount',
            fixed_amount: {
              amount: 500,
              currency: 'usd',
            },
            display_name: 'Delivery / CA Ship',
            delivery_estimate: {
              minimum: {
                unit: 'business_day',
                value: 1,
              },
              maximum: {
                unit: 'business_day',
                value: 2,
              },
            },
          },
        },
        {
          shipping_rate_data: {
            type: 'fixed_amount',
            fixed_amount: {
              amount: 1100,
              currency: 'usd',
            },
            display_name: 'Ship Outside CA',
            delivery_estimate: {
              minimum: {
                unit: 'business_day',
                value: 2,
              },
              maximum: {
                unit: 'business_day',
                value: 3,
              },
            },
          },  
        }
      ]
    else
      shipping_rates = []
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
      shipping_options: shipping_rates,
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
    order = CustomerOrder.create(stripe_checkout_id: checkout_session.id)
    # Assign bread selection (if any) to the correct orderable's notes
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
    when 'payment_method.attached'
      payment_method = event['data']['object']
      attach_payment(payment_method)
    when 'customer.created'
      customer = event['data']['object']

      create_customer(customer, nil, nil)
    when  'customer.updated'
      customer = event['data']['object']

      update_customer(customer)
    when 'invoice.created'
      invoice = event['data']['object']

      create_invoice(invoice)
    when 'invoice.updated'
    when 'invoice.upcoming'
    when 'invoice.paid'
    when 'invoice.payment_succeeded'
      invoice = event['data']['object']
      
      pay_invoice(invoice.id)
    when 'invoice.finalized' 
      invoice = event['data']['object']

      finalize_invoice(invoice)
    when 'customer.subscription.created'
      subscription = event['data']['object']

      attach_subscription(subscription)
    when 'customer.subscription.updated'
      subscription = event['data']['object']
      
      update_subscription_status(subscription)
    when 'customer.subscription.deleted'
      subscription = event['data']['object']
      
      cancel_subscription(subscription)
    when 'payment_intent.succeeded'
    when 'payment_intent.created'
    when 'charge.succeeded'
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
    head :ok
    # status 200
  end

  private
  def create_order(checkout_session)
    begin
      order = CustomerOrder.find_by_stripe_checkout_id(checkout_session.id)
      consent = checkout_session.consent.promotions == "opt_in" ? true : false
      shipping_amount = checkout_session.shipping_cost.present? ? checkout_session.shipping_cost.amount_total : 0
      fulfillment = shipping_amount > 0 ? "Ship" : checkout_session.custom_fields.first.dropdown.value 
      if checkout_session.mode == "subscription"
        invoice = Stripe::Invoice.retrieve(checkout_session.invoice)
        intent = Stripe::PaymentIntent.retrieve(invoice.payment_intent) 
      else
        intent = Stripe::PaymentIntent.retrieve(checkout_session.payment_intent)
      end
      create_address(checkout_session, order)
      create_payment_method(intent, order)
      order.update(stripe_id: checkout_session.id, amount: checkout_session.amount_total, fulfillment_method: fulfillment, subscription_id: checkout_session.subscription )
      create_customer(checkout_session.customer_details, order, consent)
      # customer = Customer.where(email: checkout_session.customer_details.email).first_or_create
      # customer.update(promotion_consent: consent)
      # customer.customer_orders << order
      if checkout_session.mode == "subscription"
        attach_invoice(invoice.id, order)
      end
    end
    puts "Created order ##{order.guid} for #{checkout_session.inspect}"
  end
  
  def create_payment_method(intent, order)
    return if order.payment_method.present?
    payment_method = Stripe::PaymentMethod.retrieve(intent.payment_method)
    charge = Stripe::Charge.retrieve(intent.latest_charge)
    if charge.payment_method_details.type == "card"
      card = charge.payment_method_details.card
      pass_check = card.checks.cvc_check == "pass" ? true : false
      order_payment = PaymentMethod.create_with(card_type: card.brand, 
        cvc_check: pass_check, 
        last_4: card.last4,
        customer_order: order).find_or_create_by(stripe_id: payment_method.id)
    else
      order_payment = PaymentMethod.create_with(card_type: charge.payment_method_details.type, 
        cvc_check: true, 
        last_4: "",
        customer_order: order).find_or_create_by(stripe_id: payment_method.id)
    end
    puts "Created Payment Method for #{order_payment.inspect}"
  end

  def create_customer(customer, order, consent)
    return unless customer.email.present?
    stripe_customer = Stripe::Customer.search(query: 'email:'"'#{customer.email}'")
    if stripe_customer.present?
      customer = stripe_customer.first
      stripe_id = customer.id
    else
      customer = customer
      stripe_id = nil
    end
    order_customer = Customer.create_with(promotion_consent: consent, phone: customer.phone, name: customer.name, stripe_id: stripe_id ).find_or_create_by(email: customer.email)
    order_customer.customer_orders << order if order.present?
    puts "Created #{order_customer.name} for #{stripe_customer.inspect}"
  end

  def create_address(checkout_session, order)
    address = Address.create(street_1: checkout_session.shipping_details.address.line1,
      street_2: checkout_session.shipping_details.address.line2, 
      city: checkout_session.shipping_details.address.city, 
      state: checkout_session.shipping_details.address.state, 
      postal: checkout_session.shipping_details.address.postal_code,
      name: checkout_session.shipping_details.name,
      customer_order: order
    )
    puts "Created Address for #{checkout_session.inspect}"
  end

  def create_invoice(invoice)
    stripe_invoice = Stripe::Invoice.retrieve(invoice.id)
    if stripe_invoice.subscription.present?
      customer_order = CustomerOrder.find_by_subscription_id(stripe_invoice.subscription)
    else
      stripe_customer = Stripe::Customer.retrieve(stripe_invoice.customer)
      customer = Customer.create_with(phone: stripe_customer.phone, name: stripe_customer.name).find_or_create_by(stripe_id: stripe_customer.id)
      customer_order = customer.customer_orders.create
    end
    new_invoice = Invoice.find_or_create_by(invoice_id: stripe_invoice.id, customer_order: customer_order)
    time_start = Time.at(stripe_invoice.period_start.to_i)
    time_end = Time.at(stripe_invoice.period_end.to_i)
    new_invoice.update(subscription_id: stripe_invoice.subscription, period_start: time_start, period_end: time_end,
      amount_due: stripe_invoice.amount_due, invoice_status: stripe_invoice.status
    )
    order = CustomerOrder.find(customer_order.id)
    order.invoices << new_invoice
    puts "Created invoice ##{new_invoice.id}"
  end

  def finalize_invoice(invoice)
    stripe_invoice = Stripe::Invoice.retrieve(invoice.id)
    order_invoice = Invoice.find_by(invoice_id: stripe_invoice.id)
    customer_order = order_invoice.customer_order
    if customer_order.present? && customer_order.orderables.blank?
      cart = Cart.create
      for line in  stripe_invoice.lines
        variation = Variation.find_by(stripe_id: line.price.id)
        customer_order.orderables.create(variation: variation, quantity: line.quantity, cart: cart, current: true)
      end
    end
    time_start = Time.at( stripe_invoice.period_start.to_i)
    time_end = Time.at( stripe_invoice.period_end.to_i)
    order_invoice.update(period_start: time_start, period_end: time_end,
      amount_due:  stripe_invoice.amount_due, invoice_status:  stripe_invoice.status
    )
    if stripe_invoice.status == "paid"
      order_invoice.paid!
    end
  end

  def update_customer(customer)
    stripe_customer = Stripe::Customer.retrieve(customer.id)
    order_customer = Customer.find_or_create_by(stripe_id: stripe_customer.id)
    return unless stripe_customer.email != order_customer.email
    order_customer.update(email: stripe_customer.email, phone: stripe_customer.phone, name: stripe_customer.name)
    puts "Updated #{customer.name} for #{stripe_customer.inspect}"
  end

  def attach_invoice(invoice, order)
    stripe_invoice = Stripe::Invoice.retrieve(invoice)
    time_start = Time.at(stripe_invoice.period_start.to_i)
    time_end = Time.at(stripe_invoice.period_end.to_i)
    order_invoice = Invoice.create_with(subscription_id: stripe_invoice.subscription, period_start: time_start, period_end: time_end,
      amount_due: stripe_invoice.amount_due, invoice_status: stripe_invoice.status).find_or_create_by(invoice_id: invoice, customer_order: order)
  end

  def attach_payment(payment_method)
    payment = Stripe::PaymentMethod.retrieve(payment_method)
    customer = Customer.find_by_stripe_id(payment.customer)
    card = payment.card
    pass_check = card.checks.cvc_check == "pass" ? true : false
    order_payment = PaymentMethod.create_with(card_type: card.brand, 
      cvc_check: pass_check, 
      last_4: card.last4)
    customer.payment_method << order_payment
  end
  
  def attach_subscription(subscription)
    stripe_subscription = Stripe::Subscription.retrieve(subscription.id)
    stripe_customer = Stripe::Customer.retrieve(stripe_subscription.customer)
    customer = Customer.find_by_stripe_id(stripe_customer.id)
    order = CustomerOrder.find_by_customer_id(customer.id)
    price = stripe_subscription.items.first.price.id
    unless order.variations.exists?(stripe_id: price)
      variation = Variation.find_by_stripe_id(price)
      cart = Cart.create
      order.orderables.last.update(current: false) if order.orderables.size > 1
      order.orderables.create(variation: variation, quantity: stripe_subscription.items.first.quantity, cart: cart, current: true, subscription_id: stripe_subscription.id)
    end
    order.update(subscription_status: stripe_subscription.status, subscription_id: stripe_subscription.id)
    
    puts "Updated Subscription"
  end

  def update_subscription_status(subscription)
    orderable = Orderable.find_by_subscription_id(subscription.id)
    order = orderable.customer_order
    return unless order.present?
    stripe_subscription = Stripe::Subscription.retrieve(subscription.id)
    price = stripe_subscription.items.first.price.id
    if subscription.pause_collection.present?
      sub_status = "paused"
    else
      sub_status = stripe_subscription.status
    end
    unless order.variations.exists?(stripe_id: price)
      variation = Variation.find_by_stripe_id(price)
      orderable = order.orderables.create(variation: variation, quantity: stripe_subscription.items.first.quantity, cart: order.orderables.first.cart, current: true, subscription_id: stripe_subscription.id)
      previous_orders = order.orderables.where.not(orderables: {customer_order_id: orderable.id})
      for previous_order in previous_orders
        previous_order.update(current: false)
      end
    end
    order.update(subscription_status: sub_status)
    puts "Updated Subscription"
  end

  def cancel_subscription(subscription)
    stripe_subscription = Stripe::Subscription.retrieve(subscription.id)
    orderable = Orderable.find_by_subscription_id(subscription.id)
    order = orderable.customer_order
    order.update(subscription_status: stripe_subscription.status, canceled_at: stripe_subscription.canceled_at)
    orderable.update(current: false)
    puts "Cancel Subscription"
  end

  def process_order(checkout_session)
    order = CustomerOrder.find_by_stripe_checkout_id(checkout_session.id)
    if order.orderables.trackable.any?
      adjustments = order.orderables.trackable
      adjustments.each do |adjustment|
        adjustment.variation.adjust_count_on_hand(adjustment.quantity)
      end
    end
    pay_invoice(checkout_session.invoice) if checkout_session.mode == "subscription"
    order.processed!
    puts "Processed ##{order.guid} for #{order.orderables.inspect}"
  end

  def pay_invoice(invoice)
    stripe_invoice = Stripe::Invoice.retrieve(invoice)
    order_invoice = Invoice.find_by(invoice_id: invoice)
    intent = Stripe::PaymentIntent.retrieve(stripe_invoice.payment_intent)
    customer_order = order_invoice.customer_order
    create_payment_method(intent, customer_order) unless customer_order.payment_method.present?
    order_invoice.update(amount_paid: stripe_invoice.amount_paid, invoice_status: stripe_invoice.status)
    order_invoice.paid!
  end

  def email_customer_about_failed_payment(checkout_session)
    order = Order.find_by_stripe_id(checkout_session.payment_intent)
    order.failed!
    puts "Emailing customer about payment failure for: #{checkout_session.inspect}"
  end
end