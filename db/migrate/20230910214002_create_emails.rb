class CreateEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :emails do |t|
      t.datetime :date_sent
      t.string :subject
      t.references :customer, null: true, foreign_key: true

      t.timestamps
    end
  end
end
