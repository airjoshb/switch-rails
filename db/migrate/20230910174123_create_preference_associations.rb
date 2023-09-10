class CreatePreferenceAssociations < ActiveRecord::Migration[7.0]
  def change
    create_table :preference_associations do |t|
      t.references :preference, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.references :variation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
