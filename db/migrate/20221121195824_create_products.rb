class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.string :image
      t.integer :row_order
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
