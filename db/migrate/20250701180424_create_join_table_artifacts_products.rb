class CreateJoinTableArtifactsProducts < ActiveRecord::Migration[7.1]
  def change
    create_join_table :artifacts, :products do |t|
      t.index [:artifact_id, :product_id]
      t.index [:product_id, :artifact_id]
    end
  end
end
