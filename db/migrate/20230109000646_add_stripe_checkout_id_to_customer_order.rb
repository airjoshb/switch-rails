class AddStripeCheckoutIdToCustomerOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :customer_orders, :stripe_checkout_id, :string
  end
end
