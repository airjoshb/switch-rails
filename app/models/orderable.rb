class Orderable < ApplicationRecord
  belongs_to :variation
  belongs_to :cart
  belongs_to :customer_order, optional: true

  def total
    variation.amount * quantity
  end
end
