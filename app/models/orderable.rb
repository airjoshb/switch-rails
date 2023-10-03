class Orderable < ApplicationRecord
  belongs_to :variation
  belongs_to :cart
  belongs_to :customer_order, optional: true

  scope :current_sub, -> { where( current: true )}


  def total
    variation.amount * quantity
  end
end
