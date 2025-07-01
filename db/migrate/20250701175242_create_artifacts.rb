class CreateArtifacts < ActiveRecord::Migration[7.1]
  def change
    create_table :artifacts do |t|
      t.string :name
      t.string :url
      t.references :category, null: false, foreign_key: true
      t.string :slug

      t.timestamps
    end
  end
end
