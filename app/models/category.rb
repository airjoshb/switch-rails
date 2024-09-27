class Category < ApplicationRecord
  has_many :products
  has_many :posts
  has_one_attached :image, dependent: :destroy

  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  # default_scope { order(:row_order) }

  scope :active, -> { where(active: :true) }
  scope :categories, -> { where.not(name: "All")}
end
