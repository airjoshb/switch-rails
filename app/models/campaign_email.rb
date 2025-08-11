class CampaignEmail < ApplicationRecord
  belongs_to :campaign
  belongs_to :email
  
  def self.ransackable_attributes(auth_object = nil)
    ["email_id", "campaign_id"]
  end
end