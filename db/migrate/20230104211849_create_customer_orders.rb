class CreateCustomerOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_orders do |t|
      t.string :guid
      t.string :stripe_id
      t.decimal :amount
      t.decimal :fee
      t.decimal :net
      t.text :description
      t.datetime :completed_at

      t.timestamps
    end
  end
end
