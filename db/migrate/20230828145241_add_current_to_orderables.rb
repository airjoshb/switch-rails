class AddCurrentToOrderables < ActiveRecord::Migration[7.0]
  def change
    add_column :orderables, :current, :boolean
  end
end
