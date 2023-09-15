class AddLastBoxDateToCustomerOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :customer_orders, :last_box_date, :datetime
  end
end
