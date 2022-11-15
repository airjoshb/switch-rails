class CreateCheckoutSessionsController < ApplicationController

  # This example sets up an endpoint using the Sinatra framework.
  # Watch this video to get started: https://youtu.be/8aA9Enb8NVc.
  require 'stripe'

  # Set your secret key. Remember to switch to your live secret key in production.
  # See your keys here: https://dashboard.stripe.com/apikeys
  Stripe.api_key = 'sk_test_W8RvelVgJxdVMlZoZhggagqm'
  Stripe.api_version = '2015-04-07; cart_sessions_beta=v1;'

  def create
    cart_session_cookie = cookies[:cart_session]

    if !cart_session_cookie
      return status 400
    end

    checkout_session = Stripe::Checkout::Session.create({
      line_items: [{
        # Provide the exact Price ID (e.g. pr_1234) of the product you want to sell
        price: 'price_0M0rswllDkp2GQCBg6NMiyOG',
        quantity: 1,
      }],
      mode: 'payment',
      success_url: 'http://localhost:3000/',
      cancel_url: 'http://localhost:3000/',
    })

    # {checkoutUrl: checkout_session.url}.to_json
    redirect_to checkout_session.url, allow_other_host: true, status: 303
  end
end