Rails.application.routes.draw do
  mount Avo::Engine, at: Avo.configuration.root_path
  get  'sign_in', to: 'sessions#new'
  post 'sign_in', to: 'sessions#create'
  post 'logout', to: 'sessions#delete'
  get  'sign_up', to: 'registrations#new'
  post 'sign_up', to: 'registrations#create'
  
  get 'orders/show'
  get 'cart', to: 'cart#show'
  get 'cart/cancel', to: 'cart#cancel'
  get 'cart/success', to: 'cart#success'
  post 'cart/add'
  post 'cart/remove'
  resources :charges, only: [:new]
  post 'charge', to: 'charges#charge'
  
  resources :sessions, only: [:index, :show, :destroy]
  resource  :password, only: [:edit, :update]
  namespace :identity do
    resource :email,              only: [:edit, :update]
    resource :email_verification, only: [:edit, :create]
    resource :password_reset,     only: [:new, :edit, :create, :update]
  end

  root 'main#index'
  resources :products 
  get '/p/:slug', to: 'pages#show', as: :page
  get '/shop', to: 'products#index', as: 'shop'
  post '/create-checkout-session', to: 'create_checkout_sessions#create', as: 'checkout-session'
  post '/webhooks', to: 'create_checkout_sessions#webhooks', as: 'webhooks'
end
