class Orderable < ApplicationRecord
  belongs_to :variation
  belongs_to :cart

  def total
    variation.amount * quantity
  end
end
