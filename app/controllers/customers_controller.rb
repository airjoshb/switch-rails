class CustomersController < ApplicationController
  invisible_captcha only: [:create], honeypot: :subtitle
  before_action :set_customer, only: [:unsubscribe]
  def new
    @customer = Customer.new
    @customer.fan_comments.build
  end

  def create
    @customer = Customer.find_or_initialize_by(email: customer_params[:email])
    @customer.assign_attributes(customer_params)
    if !@customer.save
      render :new
    else 
      render :create
    end
  end

  def unsubscribe
    @customer.update(promotion_consent: false, fan: false)
  end

  private
    def set_customer
      @customer = Customer.find(params[:id])
    end

    def customer_params
      params.require(:customer).permit(:email, :name, :promotion_consent, :fan, fan_comments_attributes: [:comment])
    end
end
