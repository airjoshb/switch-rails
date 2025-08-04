class Preference < ApplicationRecord
  has_many :preference_associations, dependent: :destroy
  has_many :customers, through: :preference_associations
  has_many :variations, through: :preference_associations
  has_many :orderables, through: :preference_associations

  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]
end
