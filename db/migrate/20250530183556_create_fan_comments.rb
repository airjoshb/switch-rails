class CreateFanComments < ActiveRecord::Migration[7.1]
  def change
    create_table :fan_comments do |t|
      t.string :comment
      t.belongs_to :customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
