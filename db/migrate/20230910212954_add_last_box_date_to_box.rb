class AddLastBoxDateToBox < ActiveRecord::Migration[7.0]
  def change
    add_column :boxes, :last_box_date, :datetime
  end
end
