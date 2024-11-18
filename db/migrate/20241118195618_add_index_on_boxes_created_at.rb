class AddIndexOnBoxesCreatedAt < ActiveRecord::Migration[7.1]
  def change
    add_index :boxes, :created_at
  end
end
