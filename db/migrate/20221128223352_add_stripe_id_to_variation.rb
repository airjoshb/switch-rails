class AddStripeIdToVariation < ActiveRecord::Migration[7.0]
  def up
    create_enum :interval_type, [:day, :week, :month, :year]

    change_table :variations do |t|
      t.string :stripe_id
      t.enum :interval, enum_type: "interval_type"
      t.integer :interval_count
    end
  end

  def down
    change_table :variations do |t|
      t.remove :stripe_id
      t.remove :interval
      t.remove :interval_count
    end

    execute <<-SQL
      DROP TYPE interval_type;
    SQL
  end
end
