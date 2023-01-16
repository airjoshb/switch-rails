class PaymentMethod < ApplicationRecord
  belongs_to :customer_order
end
