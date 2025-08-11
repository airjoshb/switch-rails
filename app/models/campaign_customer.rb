class CampaignCustomer < ApplicationRecord
  belongs_to :campaign
  belongs_to :customer

  def self.ransackable_attributes(auth_object = nil)
    ["customer_id", "campaign_id"]
  end
end
