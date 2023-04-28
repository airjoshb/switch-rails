class AddFulfillmentMethodToCustomerOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :customer_orders, :fulfillment_method, :string
  end
end
