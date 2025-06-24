class RenameReferencesCampaignsCustomers < ActiveRecord::Migration[7.1]
  def change
    rename_column :campaigns_customers, :campaigns_id, :campaign_id
    rename_column :campaigns_customers, :customers_id, :customer_id
  end
end
