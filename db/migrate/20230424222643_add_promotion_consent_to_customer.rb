class AddPromotionConsentToCustomer < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :promotion_consent, :boolean
  end
end
