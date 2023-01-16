class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.string :street_1
      t.string :street_2
      t.string :city
      t.string :state
      t.string :postal
      t.boolean :address_check
      t.belongs_to :customer_order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
