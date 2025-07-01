class AddDeliveryMethodToOrderables < ActiveRecord::Migration[7.1]
  def change
    add_column :orderables, :delivery_method, :string
  end
end
