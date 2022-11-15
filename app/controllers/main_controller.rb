class MainController < ApplicationController
    def index
      @cart_session=cookies[:cart_session]
    end
end
