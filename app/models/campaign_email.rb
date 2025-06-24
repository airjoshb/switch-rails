class CampaignEmail < ApplicationRecord
  belongs_to :campaigns
  belongs_to :emails
end
