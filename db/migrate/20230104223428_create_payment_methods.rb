class CreatePaymentMethods < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_methods do |t|
      t.string :stripe_id
      t.string :last_4
      t.belongs_to :customer_order, null: false, foreign_key: true
      t.boolean :cvc_check
      t.string :card_type

      t.timestamps
    end
  end
end
