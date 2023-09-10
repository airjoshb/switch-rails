class AddCustomerOrderToBox < ActiveRecord::Migration[7.0]
  def change
    add_reference :boxes, :customer_order, null: true, foreign_key: true
  end
end
