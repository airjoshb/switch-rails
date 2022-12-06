class CreateVariations < ActiveRecord::Migration[7.0]
  def up    
    create_table :variations do |t|
      t.string :name
      t.belongs_to :product, null: false, foreign_key: true
      t.string :image
      t.decimal :price, precision: 10, scale: 2
      t.boolean :active, default: true
      t.boolean :add_on
      t.integer :count_on_hand, default: 0
      t.integer :unit_quantity
      t.integer :row_order
      t.boolean :recurring

      t.timestamps
    end
  end

  def down
    drop_table :variations
  end

end
