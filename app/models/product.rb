class Product < ApplicationRecord

  has_many :variations, -> {order('variations.row_order')}
  belongs_to :category, optional: true
  has_and_belongs_to_many :artifacts
  accepts_nested_attributes_for :variations, allow_destroy: true
  
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  has_one_attached :image, dependent: :destroy
  has_many_attached :trix_attachments
  
  has_rich_text :content
  has_rich_text :description

  default_scope { order(row_order: :asc) }
  scope :active, -> { where(active: true)}
  
  after_commit :sync_stripe_product, on: %i[create update], if: :saved_changes?

  
  def available?
    self.active
  end

  def subscription?
    self.recurring
  end

  private

  def sync_stripe_product
    return if ENV['STRIPE_SECRET_KEY'].blank?

    require 'stripe'
    Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY')
    plain_description = description&.to_plain_text.to_s.strip
    stripe_product_attributes = {
      name: name,
      shippable: variations.infinite.exists?
    }
    stripe_product_attributes[:description] = plain_description if plain_description.present?

    if stripe_id.present?
      Stripe::Product.update(stripe_id, stripe_product_attributes)
    else
      stripe_product = Stripe::Product.create(stripe_product_attributes)
      update_column(:stripe_id, stripe_product.id)
    end
  rescue Stripe::StripeError => e
    Rails.logger.error("Product #{id} Stripe sync failed: #{e.class} #{e.message}")
  rescue StandardError => e
    Rails.logger.error("Product #{id} sync failed: #{e.class} #{e.message}")
  end

  # Try building a slug based on the following fields in
  # increasing order of specificity.
  # def slug_candidates
  #   [
  #     :name,
  #     %i[name something_else]
  #   ]
  # end
end
