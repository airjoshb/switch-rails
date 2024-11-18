class AddIndexOnProductsCreatedAt < ActiveRecord::Migration[7.1]
  def change
    add_index :products, :created_at
  end
end
