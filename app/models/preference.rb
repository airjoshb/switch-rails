class Preference < ApplicationRecord
  has_many :preference_associations, dependent: :destroy, inverse_of: :preference
  has_many :customers, through: :preference_associations
  has_many :variations, through: :preference_associations
  has_many :customer_orders, through: :preference_associations

  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]
end
