class AddOptionsToPreferences < ActiveRecord::Migration[7.1]
  def change
    add_column :preferences, :options, :string
  end
end
