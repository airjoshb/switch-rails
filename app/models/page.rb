class Page < ApplicationRecord
  has_rich_text :content

  has_many_attached :trix_attachments

  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]
end
