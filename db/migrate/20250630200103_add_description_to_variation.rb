class AddDescriptionToVariation < ActiveRecord::Migration[7.1]
  def change
    add_column :variations, :description, :text
  end
end
