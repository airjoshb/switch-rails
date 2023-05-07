class AddDraftToInvoice < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  def change
    execute <<-SQL
        ALTER TYPE state ADD VALUE IF NOT EXISTS 'draft' BEFORE 'open';
      SQL
  end
end
