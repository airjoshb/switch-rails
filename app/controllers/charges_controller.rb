require 'stripe'

class ChargesController < ApplicationController

  def new

  end

  def charge
    Stripe.api_key = 'sk_test_W8RvelVgJxdVMlZoZhggagqm'
    @cart_total = Cart.find(params[:cart_id]).total.to_i
    payment_intent = Stripe::PaymentIntent.create(
      amount: @cart_total,
      currency: 'usd',
      automatic_payment_methods: {
        enabled: true,
      },
    )
    puts payment_intent
    clientSecret = payment_intent['client_secret']
    
    render json: {
      clientSecret: payment_intent["client_secret"],
    }
  end
end
