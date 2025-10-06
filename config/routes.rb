require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"
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
  resources :orderables do
    member do
      patch :update_notes
    end
  end
  resources :customer_boxes, only: [:show] do
    member do
      patch :add_ons, to: "customer_boxes#update_add_ons"
      post :complete_order, to: "customer_boxes#complete_order"
    end
  end
  post 'orderables/:id/remove', to: 'customer_boxes#remove', as: :remove_orderable
  resources :customers, only: [:new, :create]
  get 'customers/unsubscribe'
  patch 'customers/unsubscribe'
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
  get "/sitemap" => redirect("tools/sitemap")
  get "/tools/sitemap" => "sitemap#index", :as => :sitemap_tools, :defaults => {:format => :xml}
  resources :products 
  resources :updates, controller: :posts
  get "p/Home" => redirect("/")
  get "p/home" => redirect("/")
  get '/feed', to: 'posts#feed', as: :feed
  get '/p/:slug', to: 'pages#show', as: :page
  get '/shop', to: 'products#index', as: 'shop'
  post '/create-checkout-session', to: 'create_checkout_sessions#create', as: 'checkout-session'
  post '/webhook', to: 'create_checkout_sessions#webhook', as: 'webhook'

  # config/routes.rb
  direct :cdn_image do |model, options|
    expires_in = options.delete(:expires_in) { ActiveStorage.urls_expire_in }

    if model.respond_to?(:signed_id)
      route_for(
        :rails_service_blob_proxy,
        model.signed_id(expires_in: expires_in),
        model.filename,
        options.merge(host: ENV.fetch('CDN_HOST'))
      )
    else
      signed_blob_id = model.blob.signed_id(expires_in: expires_in)
      variation_key  = model.variation.key
      filename       = model.blob.filename

      route_for(
        :rails_blob_representation_proxy,
        signed_blob_id,
        variation_key,
        filename,
        options.merge(host: ENV.fetch('CDN_HOST'))
      )
    end
  end

end
