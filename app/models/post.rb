class Post < ApplicationRecord
  belongs_to :category, optional: true
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]
  has_and_belongs_to_many :artifacts
  has_one_attached :image, dependent: :destroy
  has_many_attached :trix_attachments
  
  has_rich_text :content

  default_scope  { order(created_at: :desc) }

  def shortened_content(amount = nil)
    fragment = Nokogiri::HTML::DocumentFragment.parse(content.body.to_s)
    first_block = fragment.css('p, ul, ol, blockquote, h1, h2, h3, h4, h5, h6').find { |node| node.text.squish.present? }

    if first_block.present?
      return first_block.to_html.html_safe if amount.blank?

      truncated_text = first_block.text.squish.truncate(amount)
      return "<p>#{ERB::Util.html_escape(truncated_text)}</p>".html_safe
    end

    fallback_text = content.to_plain_text.to_s.squish
    amount.present? ? fallback_text.truncate(amount) : fallback_text
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
