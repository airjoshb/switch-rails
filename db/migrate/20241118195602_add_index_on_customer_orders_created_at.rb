class AddIndexOnCustomerOrdersCreatedAt < ActiveRecord::Migration[7.1]
  def change
      add_index :customer_orders, :created_at
  end
end
