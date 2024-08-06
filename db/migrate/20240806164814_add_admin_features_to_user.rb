class AddAdminFeaturesToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :mode, :integer
    add_column :users, :notice, :string
  end
end
