class AddCustomerOrderToOrderables < ActiveRecord::Migration[7.0]
  def change
    add_reference :orderables, :customer_order, foreign_key: true
  end
end
