class Customer < ApplicationRecord
  has_many :customer_orders
  has_many :emails
  has_many :invoices, through: :customer_orders
  has_many :addresses, through: :customer_orders
  has_many :payment_methods, through: :customer_orders
  has_many :orderables, through: :customer_orders, inverse_of: :customer_orders
  has_many :preference_associations, dependent: :destroy, inverse_of: :customer
  has_many :preferences, through: :preference_associations
end
