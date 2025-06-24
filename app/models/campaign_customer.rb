class CampaignCustomer < ApplicationRecord
  belongs_to :campaigns
  belongs_to :customers
end
