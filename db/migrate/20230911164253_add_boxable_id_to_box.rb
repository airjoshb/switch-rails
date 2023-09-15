class AddBoxableIdToBox < ActiveRecord::Migration[7.0]
  def change
    add_column :boxes, :boxable_id, :integer
    add_column :boxes, :boxable_type, :string
  end
end
