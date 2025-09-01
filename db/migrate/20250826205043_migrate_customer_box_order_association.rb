class MigrateCustomerBoxOrderAssociation < ActiveRecord::Migration[7.1]
  def up
    Box.find_each do |box|
      if box.customer_order_id.present?
        execute <<-SQL
          INSERT INTO boxes_customer_orders (box_id, customer_order_id)
          VALUES (#{box.id}, #{box.customer_order_id})
        SQL
      end
    end
  end

  def down
    # Optionally, remove associations if rolling back
    execute "DELETE FROM boxes_customer_orders"
  end
end