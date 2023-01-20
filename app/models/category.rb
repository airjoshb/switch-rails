class Category < ApplicationRecord
  has_many :products
  has_one_attached :image, dependent: :destroy

  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  default_scope { order(:name) }

end
