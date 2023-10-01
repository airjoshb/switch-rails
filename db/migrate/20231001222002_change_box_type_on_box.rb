class ChangeBoxTypeOnBox < ActiveRecord::Migration[7.0]
  def change
    rename_column :boxes, :boxable_id, :box_id
    rename_column :boxes, :boxable_type, :type
  end
end
