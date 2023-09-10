class CreateBoxes < ActiveRecord::Migration[7.0]
  def change
    create_table :boxes do |t|
      t.datetime :date

      t.timestamps
    end
  end
end
