class ChangeStripIdToNullForCustomer < ActiveRecord::Migration[7.0]
  def change
    change_column_null(:customers, :stripe_id, true )
  end
end
