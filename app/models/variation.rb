class Variation < ApplicationRecord
  belongs_to :product
  has_many :orderables
  has_many :carts, through: :orderables
  has_many :preference_associations, dependent: :destroy, inverse_of: :variation
  has_many :preferences, through: :preference_associations
  has_many :box_variations, dependent: :destroy, inverse_of: :variation
  has_many :boxes, through: :box_variations
  has_many :customer_boxes, through: :box_variations, foreign_key: :box_id
  
  enum inventory_type: {infinite: 'infinite', trackable: 'trackable'}
  enum interval: { day: 'day', week: 'week', month: 'month', year: 'year'}, _prefix: true

  after_save :init_count_on_hand, if: Proc.new { |p| p.count_on_hand.blank? }
  after_update :price_create, if: :changeable?
  after_update :variation_change, if: :name_previously_changed?
  after_save :price_create, if: :id_previously_changed?

  default_scope { order(row_order: :asc) }

  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  scope :in_stock, -> { where('count_on_hand > ? OR inventory_type = ? ', 0, :infinite, false) }
  scope :trackable, -> { where(inventory_type: :trackable)}
  scope :infinite, -> { where(inventory_type: :infinite)}
  scope :recurring, -> { where(recurring: true)}
  scope :add_ons, -> { where(add_on: true)}
  scope :active, -> { where(active: true)}
  scope :preference, -> (preference) { joins(:preferences).where(preferences: { name: preference }) }

  def available?
    self.active
  end

  def add_on?
    self.add_on
  end

  def recurring?
    self.recurring
  end

  def preference_filter(preference)
    joins(:preferences).where(preferences: {name: preference})
  end

  def adjust_count_on_hand(value)
    with_lock do
      set_count_on_hand(count_on_hand - value)
    end
  end

  def set_count_on_hand(value)
    self.count_on_hand = value
    count_on_hand - count_on_hand_was
    save!
  end

  def in_stock?
    return true if inventory_type == 'infinite'
    count_on_hand > 0
  end

  def reduce_count_on_hand_to_zero
    set_count_on_hand(0) if count_on_hand > 0
  end

  private

  def price_create
    require 'stripe'
    Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY')
    unless self.stripe_id.blank? 
      price = Stripe::Price.retrieve(self.stripe_id) 
      Stripe::Price.update( price.id, {active: false})
    end
    stripe_price = Stripe::Price.create({
      product: self.product.stripe_id,
      currency: 'usd',
      unit_amount: self.amount.to_i,
      nickname: "#{self.name} (#{self.unit_quantity})",
      recurring: self.recurring? ? {interval: self.interval, interval_count: self.interval_count} : nil
    })
    self.update_columns(stripe_id: stripe_price.id)
  end

  def changeable?
    self.saved_change_to_amount? || self.saved_change_to_interval? || self.saved_change_to_interval_count? || self.saved_change_to_recurring?
  end

  def variation_change
    require 'stripe'
    Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY')
    Stripe::Price.update(
      self.stripe_id, {
        nickname: "#{self.name} (#{self.unit_quantity})",
    })
  end

  def active_change
    require 'stripe'
    Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY')
    Stripe::Price.update(
      self.stripe_id, {active: self.active})
  end

  def init_count_on_hand
    if count_on_hand.blank?
      self.update_attributes(count_on_hand: 0)
    end
  end

end
