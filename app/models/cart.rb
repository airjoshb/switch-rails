class Cart < ApplicationRecord
  has_many :orderables, dependent: :destroy
  has_many :variations, through: :orderables
  BREAD_CHOICES = ['Seeded', 'Brown Bread', 'Plain Loaf', "Italian Herbed", "Honey Oat"].freeze

  def total
    orderables.to_a.sum { |orderable| orderable.total }
  end

  def quantity
    orderables.to_a.sum { |orderable| orderable.quantity }
  end
end
