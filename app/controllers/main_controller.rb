class MainController < ApplicationController

  require 'stripe'

  # Set your secret key. Remember to switch to your live secret key in production.
  # See your keys here: https://dashboard.stripe.com/apikeys
  Stripe.api_key = 'sk_test_W8RvelVgJxdVMlZoZhggagqm'
  Stripe.api_version = '2015-04-07; cart_sessions_beta=v1;'

  def index
    @gallery = Dir.glob("app/assets/images/gallery/*.jpg")
  end
end
