class AddInventoryTypeToVariation < ActiveRecord::Migration[7.0] 
  def up
    create_enum :inventory, [:trackable, :infinite]

    change_table :variations do |t|
      t.enum :inventory_type, enum_type: "inventory", default: :trackable
    end
  end

  def down
    remove_column :variations, :inventory_type

    execute <<-SQL
      DROP TYPE inventory;
    SQL
  end
end
