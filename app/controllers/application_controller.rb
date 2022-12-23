class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true 

  before_action :set_render_cart
  before_action :initialize_cart
  before_action :render_nav
  
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
end
