class CreateCampaignEmails < ActiveRecord::Migration[7.1]
  def change
    create_table :campaign_emails do |t|
      t.references :campaigns, null: false, foreign_key: true
      t.references :emails, null: false, foreign_key: true

      t.timestamps
    end
  end
end
