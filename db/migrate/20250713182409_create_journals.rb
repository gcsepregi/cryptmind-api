class CreateJournals < ActiveRecord::Migration[8.0]
  def change
    create_table :journals do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.text :entry

      t.timestamps
    end
  end
end
