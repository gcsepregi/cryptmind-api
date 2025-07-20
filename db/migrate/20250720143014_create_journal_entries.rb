class CreateJournalEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :journal_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :journal_type
      t.string :title
      t.text :entry

      t.timestamps
    end
  end
end
