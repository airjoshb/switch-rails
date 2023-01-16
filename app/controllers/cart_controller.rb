class CartController < ApplicationController
  before_action :set_cart, only: :show
  
  def show
    # @render_cart = false
  end

  def success
  end

  def cancel
  end

  def add
    @cart ||= Cart.find_by(id: session[:cart_id])
    @cart = Cart.create unless @cart.present?
    session[:cart_id] = @cart.id
    @variation = Variation.find_by(id: params[:id])
    quantity = params[:quantity].to_i
    @cart.orderables.create(variation: @variation, quantity: quantity)
    # current_orderable = @cart.orderables.find_by(variation_id: @variation.id)
    # if quantity <= 0
    #   current_orderable.destroy
    # else
    #   @cart.orderables.create(variation: @variation, quantity: quantity)
    # end

    respond_to do |format|
      format.html { redirect_to cart_path }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('cart', partial: 'cart/icon', locals: {cart: @cart})
      end
    end
  end

  def remove
    Orderable.find_by(id: params[:id]).destroy

    respond_to do |format|
      format.html { redirect_to cart_path }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('cart', partial: 'cart/prices', locals: {cart: @cart})
      end
    end
  end

  private
  def set_cart
    @cart = Cart.find_by(id: session[:cart_id])
  end

end
