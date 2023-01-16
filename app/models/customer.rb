class Customer < ApplicationRecord
  has_many :customer_orders
  has_many :addresses, through: :customer_orders
  has_many :payment_methods, through: :customer_orders
  has_many :orderables, through: :customer_orders
end
