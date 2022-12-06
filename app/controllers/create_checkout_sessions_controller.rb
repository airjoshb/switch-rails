class CreateCheckoutSessionsController < ApplicationController

  # This example sets up an endpoint using the Sinatra framework.
  # Watch this video to get started: https://youtu.be/8aA9Enb8NVc.
  require 'stripe'

  # Set your secret key. Remember to switch to your live secret key in production.
  # See your keys here: https://dashboard.stripe.com/apikeys
  Stripe.api_key = 'sk_test_W8RvelVgJxdVMlZoZhggagqm'
  Stripe.api_version = '2015-04-07; cart_sessions_beta=v1;'

  def create
    cart = Cart.find(params[:cart_id])
    prices = cart.variations.group(:id).pluck('stripe_id, count(stripe_id)')
    line_items = prices.map{|e| {price:  e.first, quantity: e.last}}
    checkout_session = Stripe::Checkout::Session.create({
      line_items: line_items,
      mode: 'payment',
      success_url: 'http://localhost:3000/',
      cancel_url: 'http://localhost:3000/',
    })

    # {checkoutUrl: checkout_session.url}.to_json
    redirect_to checkout_session.url, allow_other_host: true, status: 303
  end
end