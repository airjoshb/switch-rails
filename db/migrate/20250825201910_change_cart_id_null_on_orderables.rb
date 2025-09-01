class ChangeCartIdNullOnOrderables < ActiveRecord::Migration[7.1]
  def change
    change_column_null :orderables, :cart_id, true
  end
end
