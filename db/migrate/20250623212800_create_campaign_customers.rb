class CreateCampaignCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :campaign_customers do |t|
      t.references :campaigns, null: false, foreign_key: true
      t.references :customers, null: false, foreign_key: true

      t.timestamps
    end
  end
end
