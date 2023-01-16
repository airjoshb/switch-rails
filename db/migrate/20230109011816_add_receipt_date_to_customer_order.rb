class AddReceiptDateToCustomerOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :customer_orders, :receipt_sent, :boolean
    add_column :customer_orders, :receipt_sent_date, :datetime
  end
end
