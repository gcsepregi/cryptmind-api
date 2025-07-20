class AddIsPrivateToJournalEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :journal_entries, :is_private, :boolean
  end
end
