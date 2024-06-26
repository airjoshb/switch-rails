class Customer < ApplicationRecord
  has_many :customer_orders
  has_many :customer_emails
  has_many :customer_boxes, through: :customer_orders, inverse_of: :customer
  has_many :invoices, through: :customer_orders
  has_many :addresses, through: :customer_orders
  has_many :payment_methods, through: :customer_orders
  has_many :orderables, through: :customer_orders, inverse_of: :customer_orders
  has_many :preference_associations, dependent: :destroy, inverse_of: :customer
  has_many :preferences, through: :preference_associations

  def self.ransackable_attributes(auth_object = nil)
    ["email", "name", "stripe_id"]
  end
end
