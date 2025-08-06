class AddClientIdToMoodHistories < ActiveRecord::Migration[7.0]
  def change
    add_column :mood_histories, :client_id, :string
    add_index :mood_histories, [:user_id, :client_id], unique: true
  end
end