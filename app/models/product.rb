class Product < ApplicationRecord

  has_many :variations, -> {order('variations.row_order')}
  belongs_to :category, optional: true

  accepts_nested_attributes_for :variations, allow_destroy: true
  
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  has_one_attached :image, dependent: :destroy
  has_many_attached :trix_attachments
  
  has_rich_text :content

  default_scope { order(row_order: :asc) }
  scope :active, -> { where(active: true)}
  
  after_save :product_change, if: :saved_changes?

  
  def available?
    self.active
  end

  private

  def product_change
    require 'stripe'
    Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY')
    begin
      Stripe::Product.update(
        self.stripe_id, {
        name: self.name,
        description: self.description,
        shippable: self.variations.infinite.any? ? true : false,
      })
    rescue
    stripe_product = Stripe::Product.create({
      name: self.name,
      description: self.description,
      shippable: self.variations.infinite.any? ? true : false,
    })
    self.update_columns(stripe_id: stripe_product.id)
    end
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
