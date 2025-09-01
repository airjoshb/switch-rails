class CreateCustomerBoxesCustomerOrdersJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_table :boxes_customer_orders, id: false do |t|
      t.references :box, null: false, foreign_key: true
      t.references :customer_order, null: false, foreign_key: true
    end
    add_index :boxes_customer_orders, [:box_id, :customer_order_id], unique: true, name: 'index_boxes_orders_on_box_and_order'
  end
end