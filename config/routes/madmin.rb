# Below are the routes for madmin
namespace :madmin do
  resources :orderables
  resources :carts
  namespace :action_text do
    resources :encrypted_rich_texts
  end
  namespace :action_text do
    resources :rich_texts
  end
  namespace :active_storage do
    resources :attachments
  end
  resources :products
  namespace :active_storage do
    resources :blobs
  end
  namespace :active_storage do
    resources :variant_records
  end
  resources :variations
  namespace :friendly_id do
    resources :slugs
  end
  root to: "dashboard#show"
end
