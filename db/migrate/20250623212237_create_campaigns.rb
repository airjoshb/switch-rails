class CreateCampaigns < ActiveRecord::Migration[7.1]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
