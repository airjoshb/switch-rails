class PreferenceAssociation < ApplicationRecord
  belongs_to :preference, inverse_of: :preference_associations
  belongs_to :customer, optional: true, inverse_of: :preference_associations
  belongs_to :variation, optional: true, inverse_of: :preference_associations
  belongs_to :customer_order, optional: true, inverse_of: :preference_associations

  validates :customer_id, uniqueness: { scope: :preference_id }, allow_nil: true
  validates :variation_id, uniqueness: { scope: :preference_id }, allow_nil: true
  validates :customer_order_id, uniqueness: { scope: :preference_id }, allow_nil: true
end
