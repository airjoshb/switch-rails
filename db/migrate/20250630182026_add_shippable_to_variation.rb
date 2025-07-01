class AddShippableToVariation < ActiveRecord::Migration[7.1]
  def change
    add_column :variations, :shippable, :boolean
  end
end
