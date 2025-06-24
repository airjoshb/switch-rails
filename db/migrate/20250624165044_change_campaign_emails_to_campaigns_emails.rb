class ChangeCampaignEmailsToCampaignsEmails < ActiveRecord::Migration[7.1]
  def change
    rename_table :campaign_emails, :campaigns_emails
  end
end
