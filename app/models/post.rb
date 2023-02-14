class Post < ApplicationRecord

  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  has_one_attached :image, dependent: :destroy
  has_many_attached :trix_attachments
  
  has_rich_text :content

end
