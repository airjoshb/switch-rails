class AddStatusToOrders < ActiveRecord::Migration[7.0]
  def up
    create_enum :status, [:pending, :processed, :failed, :fulfilled, :refunded]

    change_table :customer_orders do |t|
      t.enum :order_status, enum_type: "status", default: :pending
    end
  end

  def down
    remove_column :customer_orders, :order_status

    execute <<-SQL
      DROP TYPE status;
    SQL
  end
end
