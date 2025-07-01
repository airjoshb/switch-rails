class AddDescriptionToArtifacts < ActiveRecord::Migration[7.1]
  def change
    add_column :artifacts, :description, :text
  end
end
