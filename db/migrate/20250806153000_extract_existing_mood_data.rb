class ExtractExistingMoodData < ActiveRecord::Migration[7.0]
  def up
    # Get all journal entries with mood data
    journal_entries_with_mood = execute("SELECT id, user_id, mood, created_at, title, journal_type FROM journal_entries WHERE mood IS NOT NULL AND mood != ''").to_a

    # Insert mood data into mood_histories table
    journal_entries_with_mood.each do |entry|
      # Convert numeric indices to integer to access the values
      journal_type = entry[5] # journal_type is the 6th column (index 5)
      title = entry[4]        # title is the 5th column (index 4)
      notes = "Extracted from #{journal_type} journal entry: #{title}"
      execute <<-SQL
        INSERT INTO mood_histories (user_id, journal_entry_id, mood, recorded_at, notes, created_at, updated_at)
        VALUES (
          #{entry[1]},#{' '}
          #{entry[0]},#{' '}
          '#{entry[2].gsub("'", "''")}',#{' '}
          '#{DateTime.parse(entry[3].to_s).strftime('%Y-%m-%d %H:%M:%S')}',
          '#{notes.gsub("'", "''")}',
          '#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')}',
          '#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')}'
        )
      SQL
    end
  end

  def down
    execute("DELETE FROM mood_histories WHERE notes LIKE 'Extracted from%'")
  end
end
