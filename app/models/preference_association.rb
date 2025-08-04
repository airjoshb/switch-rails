class PreferenceAssociation < ApplicationRecord
  belongs_to :preference
  belongs_to :customer, optional: true
  belongs_to :variation, optional: true
  belongs_to :customer_order, optional: true

  validates :customer_id, uniqueness: { scope: :preference_id }, allow_nil: true
  validates :variation_id, uniqueness: { scope: :preference_id }, allow_nil: true
end
