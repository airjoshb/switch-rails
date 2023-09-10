class CreatePreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :preferences do |t|
      t.string :name, null: false, unique: true
      t.string :slug, unique: true

      t.timestamps
    end
  end
end
