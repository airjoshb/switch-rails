class AddPickupableToVariation < ActiveRecord::Migration[7.1]
  def change
    add_column :variations, :pickupable, :boolean
  end
end
