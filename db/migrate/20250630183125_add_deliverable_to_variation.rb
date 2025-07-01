class AddDeliverableToVariation < ActiveRecord::Migration[7.1]
  def change
    add_column :variations, :deliverable, :boolean
  end
end
