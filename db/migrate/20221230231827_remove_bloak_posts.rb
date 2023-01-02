class RemoveBloakPosts < ActiveRecord::Migration[7.0]
  def change
    drop_table :bloak_posts
    drop_table :bloak_images
  end
end
