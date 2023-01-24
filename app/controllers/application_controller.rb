class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true 
  before_action :set_render_cart
  # before_action :initialize_cart
  before_action :render_nav
  before_action :set_current_request_details
  before_action :authenticate
  # before_action do
  #   ActiveStorage::Current.host = request.base_url
  # end
  
  def set_render_cart
    @render_cart = true
  end

  def render_nav
    @pages = Page.all
    @nav = @pages.where(nav: true)
  end

  private
  def initialize_cart

    @cart ||= Cart.find_by(id: session[:cart_id])

    if @cart.nil?
      @cart = Cart.create
      session[:cart_id] = @cart.id
    end
  end

  def authenticate
    if session = Session.find_by_id(cookies.signed[:session_token])
      Current.session = session
    end
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end
end
