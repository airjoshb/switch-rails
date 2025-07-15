class Post < ApplicationRecord
  belongs_to :category, optional: true
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]
  has_and_belongs_to_many :artifacts
  has_one_attached :image, dependent: :destroy
  has_many_attached :trix_attachments
  
  has_rich_text :content

  default_scope  { order(created_at: :desc) }

  def shortened_content(amount)
    self.content.to_plain_text.split('</div>').first.split('<br>').first.truncate(amount)
  end

  def thumbnail
    self.image.variant(resize_to_fill: [200, 200, {crop: :centre}])
  end

  def medium_image
    self.image.variant(resize_to_fill: [300, 300, {crop: :centre}])
  end

  # def thumbnail
  #   Cloudinary::Utils.cloudinary_url(
  #     self.image,
  #     width: 150, height: 150, crop: :fill, gravity: 'center')
  # end

  # def medium_image
  #   Cloudinary::Utils.cloudinary_url(
  #     self.image,
  #     width: 300, height: 300, crop: :fill, gravity: 'center')
  # end

  # def large_image
  #   Cloudinary::Utils.cloudinary_url(
  #     self.image,
  #     width: 600, height: 600, crop: :scale)
  # end

end
