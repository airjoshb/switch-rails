class Customer < ApplicationRecord
  has_many :customer_orders
  has_and_belongs_to_many :campaigns
  has_many :fan_comments
  has_many :customer_emails
  has_many :emails, through: :customer_emails
  has_many :customer_boxes, through: :customer_orders, inverse_of: :customer_orders
  has_many :invoices, through: :customer_orders
  has_many :addresses, through: :customer_orders
  has_many :payment_methods, through: :customer_orders
  has_many :orderables, through: :customer_orders, inverse_of: :customer_orders
  has_many :preference_associations, dependent: :destroy, inverse_of: :customer
  has_many :preferences, through: :preference_associations

  accepts_nested_attributes_for :fan_comments, allow_destroy: true, 
  reject_if: :all_blank
  
  def emailable?
    promotion_consent?
  end

  def fanable?
    fan?
  end

  def abbrev_name(name)
    first, last = name.split(" ")
    return "#{first[0]}. #{last}"
  end

  def self.ransackable_attributes(auth_object = nil)
    ["email", "name", "stripe_id"]
  end
end
