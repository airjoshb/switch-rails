class Address < ApplicationRecord
  belongs_to :customer_order

  def full_address
    [street_1, street_2, city, state, postal].compact.join(", ")
  end
end
