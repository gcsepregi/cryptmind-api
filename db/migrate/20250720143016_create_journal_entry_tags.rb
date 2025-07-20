class CreateJournalEntryTags < ActiveRecord::Migration[8.0]
  def change
    create_table :journal_entry_tags do |t|
      t.references :journal_entry, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
