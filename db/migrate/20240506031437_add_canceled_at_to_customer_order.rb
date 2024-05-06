class AddCanceledAtToCustomerOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :customer_orders, :canceled_at, :datetime
  end
end
