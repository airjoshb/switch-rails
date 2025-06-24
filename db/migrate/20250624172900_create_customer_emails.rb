class CreateCustomerEmails < ActiveRecord::Migration[7.1]
  def change
    create_table :customer_emails do |t|
      t.belongs_to :email, null: false, foreign_key: true
      t.belongs_to :customer, null: false, foreign_key: true
      t.boolean :email_sent
      t.datetime :sent_date

      t.timestamps
    end
  end
end
