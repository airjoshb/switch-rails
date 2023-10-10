class AddSentEmailToBox < ActiveRecord::Migration[7.0]
  def change
    add_column :boxes, :email_sent, :boolean
    add_column :boxes, :email_sent_date, :datetime
  end
end
