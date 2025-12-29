class CartController < ApplicationController
  before_action :set_cart, only: :show
  
  def show
    # @render_cart = false
    @add_ons = Variation.active.add_ons
    @bread_orderable = @cart.present? ? @cart.orderables.find { |o| o.variation.preferences.any? && o.variation.preferences.any?{ |a| a.options.present? } } : nil
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
    @cart.orderables.create(variation: @variation, quantity: quantity, delivery_method: params[:delivery_method]) if @variation.present? && quantity > 0
    # current_orderable = @cart.orderables.find_by(variation_id: @variation.id)
    # if quantity <= 0
    #   current_orderable.destroy
    # else
    #   @cart.orderables.create(variation: @variation, quantity: quantity)
    # end

    respond_to do |format|
      format.html { redirect_to cart_path }
      # format.turbo_stream do
      #   render turbo_stream: turbo_stream.replace('cart', partial: 'cart/icon', locals: {cart: @cart})
      # end
    end
  end

  def remove
    orderable = Orderable.find_by(id: params[:id])
    orderable_id = orderable&.id
    orderable.destroy if orderable
    @cart = Cart.find_by(id: session[:cart_id])

    respond_to do |format|
      format.html { redirect_to cart_path }
      format.turbo_stream do
        render 'remove', locals: { orderable_id: orderable_id, cart: @cart, add_ons: Variation.active.add_ons }
      end
    end
  end

  private
  def set_cart
    @cart = Cart.find_by(id: session[:cart_id])
  end

end
