class AddPhoneToCustomer < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :phone, :string
  end
end
