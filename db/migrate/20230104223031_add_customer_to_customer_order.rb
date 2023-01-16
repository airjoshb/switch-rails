class AddCustomerToCustomerOrder < ActiveRecord::Migration[7.0]
  def change
    add_reference :customer_orders, :customer, foreign_key: true
  end
end
