class AddEmbedsToArtifacts < ActiveRecord::Migration[7.1]
  def change
    add_column :artifacts, :embed, :string
  end
end
