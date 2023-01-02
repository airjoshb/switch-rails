class AddSlugToVariations < ActiveRecord::Migration[7.0]
  def change
    add_column :variations, :slug, :string
  end
end
