Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "main#index"
  mount Bloak::Engine, at: "/blog"

  resource :cart_session
  post '/create-checkout-session', to: "create_checkout_sessions#create", as: "checkout-session"
end
