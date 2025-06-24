class AddNotesToOrderables < ActiveRecord::Migration[7.1]
  def change
    add_column :orderables, :notes, :string
  end
end
