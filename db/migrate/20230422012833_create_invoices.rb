class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.belongs_to :customer_order, foreign_key: true
      t.decimal :amount_due
      t.decimal :amount_paid
      t.boolean :attempted
      t.string :subscription_id
      t.string :invoice_id
      t.boolean :paid
      t.datetime :period_end
      t.datetime :period_start
      t.boolean :fulfilled
      t.datetime :fulfilled_date

      t.timestamps
    end
  end
end
