class AddStripeIdToCustomer < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :stripe_id, :string, null: false
  end
end
