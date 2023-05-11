class AddSubscriptionStatusToCustomerOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :customer_orders, :subscription_status, :string
  end
end
