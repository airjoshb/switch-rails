class PostFeature < ApplicationRecord
  belongs_to :feature
  belongs_to :post
end
