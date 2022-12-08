# Below are the routes for madmin
namespace :madmin do
  namespace :active_storage do
    resources :variant_records
  end
  namespace :active_storage do
    resources :attachments
  end
  namespace :action_text do
    resources :encrypted_rich_texts
  end
  namespace :friendly_id do
    resources :slugs
  end
  resources :products
  resources :pages
  resources :carts
  namespace :active_storage do
    resources :blobs
  end
  namespace :action_text do
    resources :rich_texts
  end
  resources :variations
  resources :orderables
  root to: "dashboard#show"
end
