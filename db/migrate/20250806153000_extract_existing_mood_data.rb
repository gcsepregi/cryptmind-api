class ExtractExistingMoodData < ActiveRecord::Migration[7.0]
  def up
    # Get all journal entries with mood data
    journal_entries_with_mood = execute("SELECT id, user_id, mood, created_at, title, journal_type FROM journal_entries WHERE mood IS NOT NULL AND mood != ''").to_a

    # Insert mood data into mood_histories table
    journal_entries_with_mood.each do |entry|
      notes = "Extracted from #{entry['journal_type']} journal entry: #{entry['title']}"
      execute <<-SQL
        INSERT INTO mood_histories (user_id, journal_entry_id, mood, recorded_at, notes, created_at, updated_at)
        VALUES (
          #{entry['user_id']},#{' '}
          #{entry['id']},#{' '}
          '#{entry['mood'].gsub("'", "''")}',#{' '}
          '#{entry['created_at']}',
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
