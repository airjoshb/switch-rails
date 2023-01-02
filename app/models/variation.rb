class Variation < ApplicationRecord
  belongs_to :product
  has_many :orderables
  has_many :carts, through: :orderables
  
  enum inventory_type: {infinite: 'infinite', trackable: 'trackable'}
  enum interval: { day: 'day', week: 'week', month: 'month', year: 'year'}, _prefix: true

  after_save :init_count_on_hand, if: Proc.new { |p| p.count_on_hand.blank? }
  after_save :variation_change, if: :saved_changes?

  default_scope { order(row_order: :asc) }

  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  scope :in_stock, -> { where('count_on_hand > ? OR inventory_type = ? ', 0, :infinite, false) }
  scope :trackable, -> { where(inventory_type: :trackable)}
  scope :infinite, -> { where(inventory_type: :infinite)}
  scope :recurring, -> { where(recurring: true)}

  def available?
    self.active
  end

  def add_on?
    self.add_on
  end

  def recurring?
    self.recurring
  end

  def adjust_count_on_hand(value)
    with_lock do
      set_count_on_hand(count_on_hand + value)
    end
  end

  def set_count_on_hand(value)
    self.count_on_hand = value
    count_on_hand - count_on_hand_was
    save!
  end

  def in_stock?
    return true if inventory_type = 'infinite'
    count_on_hand > 0
  end

  def reduce_count_on_hand_to_zero
    set_count_on_hand(0) if count_on_hand > 0
  end

  private

  def variation_change
    require 'stripe'
    Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY')
    begin
    Stripe::Price.update(
      self.stripe_id, {
        product: self.product.stripe_id,
        currency: 'usd',
        active: self.active,
        unit_amount: self.amount.to_i,
        nickname: "#{self.name} (#{self.unit_quantity})",
        recurring: self.recurring? ? {interval: self.interval, interval_count: self.interval_count} : nil
    })
    rescue
    stripe_price = Stripe::Price.create({
      product: self.product.stripe_id,
      currency: 'usd',
      active: self.active,
      unit_amount: self.amount.to_i,
      nickname: "#{self.name} (#{self.unit_quantity})",
      recurring: self.recurring? ? {interval: self.interval, interval_count: self.interval_count} : nil
    })
    self.update_columns(stripe_id: stripe_price.id)
    end
  end

  def init_count_on_hand
    if count_on_hand.blank?
      self.update_attributes(count_on_hand: 0)
    end
  end

end
