class Cart < ApplicationRecord
  has_many :orderables, dependent: :destroy
  has_many :variations, through: :orderables
  BREAD_CHOICES = %i[seeded brown plain herbed].freeze

  def total
    orderables.to_a.sum { |orderable| orderable.total }
  end

  def quantity
    orderables.to_a.sum { |orderable| orderable.quantity }
  end
end
