class Orderable < ApplicationRecord
  belongs_to :variation
  belongs_to :cart, optional: true
  belongs_to :customer_order, optional: true

  scope :current_sub, -> { where( current: true )}
  scope :trackable, -> { joins(:variation).where(variations: {inventory_type: :trackable}) }

  def total
    variation.amount * quantity
  end
end
