class AddFanToCustomer < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :fan, :boolean
  end
end
