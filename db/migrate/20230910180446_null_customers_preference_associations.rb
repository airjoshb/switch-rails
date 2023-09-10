class NullCustomersPreferenceAssociations < ActiveRecord::Migration[7.0]
  def change
    change_column_null(:preference_associations, :variation_id, true )
    change_column_null(:preference_associations, :customer_id, true )
  end
end
