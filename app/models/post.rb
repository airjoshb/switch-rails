class Post < ApplicationRecord

  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  has_one_attached :image, dependent: :destroy
  has_many_attached :trix_attachments
  
  has_rich_text :content

  default_scope  { order(created_at: :desc) }

  def thumbnail
    self.image.variant({thumbnail: '150x150^', gravity: 'center', extent: '150x150'})
  end

  def medium_image
    self.image.variant({resize: "300x300", gravity: "center" })
  end

end
