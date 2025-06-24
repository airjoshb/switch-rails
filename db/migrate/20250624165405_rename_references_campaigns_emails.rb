class RenameReferencesCampaignsEmails < ActiveRecord::Migration[7.1]
  def change
    rename_column :campaigns_emails, :campaigns_id, :campaign_id
    rename_column :campaigns_emails, :emails_id, :email_id
  end
end
