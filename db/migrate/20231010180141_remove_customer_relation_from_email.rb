class RemoveCustomerRelationFromEmail < ActiveRecord::Migration[7.0]
  def change
    remove_column :emails, :customer_id
  end
end
