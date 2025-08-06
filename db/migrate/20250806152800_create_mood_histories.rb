class CreateMoodHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :mood_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :journal_entry, null: true, foreign_key: true
      t.string :mood, null: false
      t.datetime :recorded_at, null: false
      t.text :notes

      t.timestamps
    end

    add_index :mood_histories, [ :user_id, :recorded_at ]
  end
end
