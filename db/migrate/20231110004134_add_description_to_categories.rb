class AddDescriptionToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :description, :string
    add_column :categories, :row_order, :integer
  end
end
