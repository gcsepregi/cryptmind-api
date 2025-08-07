class AddMetadataFieldsToJournalEntries < ActiveRecord::Migration[8.0]
  def change
    # Common Optional Metadata
    add_column :journal_entries, :mood, :string
    add_column :journal_entries, :location, :string
    
    # Diary-specific Fields
    add_column :journal_entries, :diary_date, :string
    add_column :journal_entries, :gratitude_list, :json
    add_column :journal_entries, :achievements, :json
    
    # Dream-specific Fields
    add_column :journal_entries, :dream_date, :string
    add_column :journal_entries, :lucidity_level, :integer
    add_column :journal_entries, :dream_signs, :json
    add_column :journal_entries, :dream_characters, :json
    add_column :journal_entries, :dream_emotions, :json
    add_column :journal_entries, :dream_clarity, :integer
    
    # Ritual-specific Fields
    add_column :journal_entries, :ritual_date, :string
    add_column :journal_entries, :ritual_type, :string
    add_column :journal_entries, :ritual_tools, :json
    add_column :journal_entries, :ritual_deities, :json
    add_column :journal_entries, :ritual_purpose, :string
    add_column :journal_entries, :ritual_outcome, :string
    add_column :journal_entries, :ritual_duration, :integer
  end
end