class ChangeCampaignCustomersToCampaignsCustomers < ActiveRecord::Migration[7.1]
  def change
    rename_table :campaign_customers, :campaigns_customers
  end
end
