class AddMetadataToArtifact < ActiveRecord::Migration[7.1]
  def change
    add_column :artifacts, :duration, :integer
    add_column :artifacts, :season, :integer
    add_column :artifacts, :episode, :integer
  end
end
