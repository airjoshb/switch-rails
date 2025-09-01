class AddTokenToCustomerBox < ActiveRecord::Migration[7.1]
  def change
    # migration
    add_column :boxes, :access_token, :string
    add_index :boxes, :access_token, unique: true
  end
end
