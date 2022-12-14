module Madmin
  class ApplicationController < Madmin::BaseController
    before_action :authenticate_admin_user
    before_action :set_current_request_details

    def authenticate_admin_user
      # TODO: Add your authentication logic here

      # For example, we could redirect if the user isn't an admin
      # redirect_to "/", alert: "Not authorized." unless user_signed_in? && current_user.admin?
      if session = Session.find_by_id(cookies.signed[:session_token])
        Current.session = session
      else
        redirect_to '/sign_in'
      end
      
    end

    def set_current_request_details
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
    end
  

    # Authenticate with Clearance
    # include Clearance::Controller
    # before_action :require_login

    # Authenticate with Devise
    # before_action :authenticate_user!

    # Authenticate with Basic Auth
    # http_basic_authenticate_with(name: Rails.application.credentials.admin_username, password: Rails.application.credentials.admin_password)
  end
end
