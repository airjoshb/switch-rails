class AddCascadeDeleteToCustomerRelationships < ActiveRecord::Migration[7.1]
  def up
    remove_foreign_key :customer_orders, column: :customer_id
    add_foreign_key :customer_orders, :customers, column: :customer_id, on_delete: :cascade

    remove_foreign_key :customer_emails, column: :customer_id
    add_foreign_key :customer_emails, :customers, column: :customer_id, on_delete: :cascade
  end

  def down
    remove_foreign_key :customer_orders, column: :customer_id
    add_foreign_key :customer_orders, :customers, column: :customer_id

    remove_foreign_key :customer_emails, column: :customer_id
    add_foreign_key :customer_emails, :customers, column: :customer_id
  end
end
