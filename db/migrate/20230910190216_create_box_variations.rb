class CreateBoxVariations < ActiveRecord::Migration[7.0]
  def change
    create_table :box_variations do |t|
      t.references :box, null: false, foreign_key: true
      t.references :variation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
