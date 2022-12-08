Rails.application.routes.draw do
  get 'orders/show'
  get 'cart', to: 'cart#show'
  post 'cart/add'
  post 'cart/remove'
  resources :charges, only: [:new]
  post 'charge', to: 'charges#charge'
  
  draw :madmin
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "main#index"
  # mount Bloak::Engine, at: "/blog"
  resources :products 
  get '/p/:slug', to: 'pages#show', as: :page
  get "/shop", to: "products#index", as: "shop"
  post '/create-checkout-session', to: "create_checkout_sessions#create", as: "checkout-session"
end
