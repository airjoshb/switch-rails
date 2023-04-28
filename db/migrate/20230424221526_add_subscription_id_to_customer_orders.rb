class AddSubscriptionIdToCustomerOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :customer_orders, :subscription_id, :string
  end
end
