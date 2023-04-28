class AddStatusToInvoices < ActiveRecord::Migration[7.0]
  def up
    create_enum :state, [ :open, :paid, :void, :uncollectible ]


    change_table :invoices do |t|
      t.enum :invoice_status, enum_type: "state", default: :open
    end
  end

  def down
    remove_column :invoices, :invoice_status

    execute <<-SQL
      DROP TYPE state;
    SQL
  end
end
