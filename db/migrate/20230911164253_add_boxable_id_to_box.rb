class AddBoxableIdToBox < ActiveRecord::Migration[7.0]
  def change
    add_column :boxes, :box_id, :integer
    add_column :boxes, :type, :string
  end
end
