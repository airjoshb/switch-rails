class ChangeNameForPriceInVariation < ActiveRecord::Migration[7.0]
  def change
    rename_column(:variations, :price, :amount)
  end
end
