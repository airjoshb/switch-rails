class AddCustomerOrderToPreferenceAssociations < ActiveRecord::Migration[7.1]
  def change
    add_reference :preference_associations, :customer_order, foreign_key: true
  end
end
