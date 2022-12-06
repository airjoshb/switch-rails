class CartSessionsController < ApplicationController
  protect_from_forgery except: :show
  require 'stripe'

  # Set your secret key. Remember to switch to your live secret key in production.
  # See your keys here: https://dashboard.stripe.com/apikeys
  Stripe.api_key = 'sk_test_W8RvelVgJxdVMlZoZhggagqm'
  Stripe.api_version = '2015-04-07; cart_sessions_beta=v1;'

  def show
    cart_session_cookie = cookies[:cart_session]

    if cart_session_cookie
      cart_session = Stripe::APIResource.request(
        :get,
        "/v1/cart/sessions/#{cart_session_cookie}",
      )
    end

    if !cart_session
      cart_session = Stripe::APIResource.request(
        :post, 
        "/v1/cart/sessions",
        { 
          currency: 'usd', 
          settings: { 
            allow_promotion_codes: true 
          }
        },
      )
    end

    cookies[:cart_session] = {
      value: cart_session_cookie || cart_session[0].data[:id],
      httponly: true,
      secure: true,
      samesite: 'Lax',
      maxage: 1000 * 60 * 60 * 24 * 90,  # 90 days in ms
    }
    clientSecret = cart_session[0].data[:client_secret].to_json
    respond_to do |format|
      format.json { render json: clientSecret }
    end
  end
  
end
