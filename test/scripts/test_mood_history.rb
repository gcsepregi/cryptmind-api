#!/usr/bin/env ruby
# Run this script with: rails runner test/scripts/test_mood_history.rb

# Test 1: Create a journal entry with mood
puts "Test 1: Creating a journal entry with mood"
user = User.first
if user.nil?
  puts "Error: No users found in the database"
  exit 1
end

journal_entry = user.journal_entries.create(
  title: "Test Journal Entry with Mood",
  entry: "This is a test entry to verify mood extraction",
  journal_type: "diary",
  mood: "Happy",
  is_private: true
)

puts "Journal entry created with ID: #{journal_entry.id}"
puts "Mood set to: #{journal_entry.mood}"

# Test 2: Verify mood history was created
puts "\nTest 2: Verifying mood history was created"
mood_histories = user.mood_histories.where(journal_entry_id: journal_entry.id)
if mood_histories.empty?
  puts "Error: No mood history was created for the journal entry"
else
  mood_history = mood_histories.first
  puts "Mood history created with ID: #{mood_history.id}"
  puts "Mood: #{mood_history.mood}"
  puts "Recorded at: #{mood_history.recorded_at}"
  puts "Notes: #{mood_history.notes}"
end

# Test 3: Update journal entry with a different mood
puts "\nTest 3: Updating journal entry with a different mood"
journal_entry.update(mood: "Excited")
puts "Journal entry updated with mood: #{journal_entry.mood}"

# Test 4: Verify a new mood history was created
puts "\nTest 4: Verifying a new mood history was created"
mood_histories = user.mood_histories.where(journal_entry_id: journal_entry.id).order(created_at: :desc)
if mood_histories.count < 2
  puts "Error: No new mood history was created after update"
else
  mood_history = mood_histories.first
  puts "New mood history created with ID: #{mood_history.id}"
  puts "Mood: #{mood_history.mood}"
  puts "Recorded at: #{mood_history.recorded_at}"
  puts "Notes: #{mood_history.notes}"
  puts "Total mood histories for this journal entry: #{mood_histories.count}"
end

# Test 5: Create a standalone mood entry
puts "\nTest 5: Creating a standalone mood entry"
standalone_mood = user.mood_histories.create(
  mood: "Reflective",
  recorded_at: Time.now,
  notes: "Standalone mood entry without a journal entry"
)

puts "Standalone mood history created with ID: #{standalone_mood.id}"
puts "Mood: #{standalone_mood.mood}"
puts "Recorded at: #{standalone_mood.recorded_at}"
puts "Notes: #{standalone_mood.notes}"

puts "\nAll tests completed!"
