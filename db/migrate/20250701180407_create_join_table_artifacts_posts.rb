class CreateJoinTableArtifactsPosts < ActiveRecord::Migration[7.1]
  def change
    create_join_table :artifacts, :posts do |t|
      t.index [:artifact_id, :post_id]
      t.index [:post_id, :artifact_id]
    end
  end
end
