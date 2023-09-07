class AddNameToAddress < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :name, :string
  end
end
