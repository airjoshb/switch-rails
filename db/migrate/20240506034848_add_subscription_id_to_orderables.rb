class AddSubscriptionIdToOrderables < ActiveRecord::Migration[7.0]
  def change
    add_column :orderables, :subscription_id, :string
  end
end
