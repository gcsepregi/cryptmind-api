#!/usr/bin/env ruby
# Run this script with: rails runner test/scripts/test_bulk_mood_sync.rb

# Test: Simulate a client-side bulk sync request
puts "Test: Simulating a client-side bulk sync request"

# Get the first user for testing
user = User.first
if user.nil?
  puts "Error: No users found in the database"
  exit 1
end

# Create a controller instance for testing
controller = MoodHistoriesController.new
controller.instance_variable_set(:@_current_user, user)

# Simulate params for the bulk sync request
mood_histories = [
  { id: "bulk_sync_test_1", mood: "happy", recorded_at: "2025-08-02T10:00:00.000Z" },
  { id: "bulk_sync_test_2", mood: "sad", recorded_at: "2025-08-03T14:30:00.000Z" },
  { id: "bulk_sync_test_3", mood: "excited", recorded_at: "2025-08-04T09:15:00.000Z" }
]

# First request - should create new records
puts "\nBulk sync request (create):"
params = { mood_histories: mood_histories }
controller.params = ActionController::Parameters.new(params)

# Mock the render method to capture the response
def controller.render(options)
  @render_options = options
end

# Call the sync method
controller.sync

# Display the result
render_options = controller.instance_variable_get(:@render_options)
if render_options
  puts "Response status: #{render_options[:status]}"
  
  # Check if all records were created
  client_ids = mood_histories.map { |mh| mh[:id] }
  created_records = user.mood_histories.where(client_id: client_ids)
  
  puts "Records created: #{created_records.count} of #{mood_histories.count}"
  
  created_records.each do |record|
    puts "\nRecord details:"
    puts "ID: #{record.id}"
    puts "Client ID: #{record.client_id}"
    puts "Mood: #{record.mood}"
    puts "Recorded at: #{record.recorded_at}"
  end
else
  puts "Error: No response from controller"
end

# Second request with updated moods - should update existing records
puts "\nSecond bulk sync request (update):"
updated_mood_histories = [
  { id: "bulk_sync_test_1", mood: "neutral", recorded_at: "2025-08-02T10:00:00.000Z" },
  { id: "bulk_sync_test_2", mood: "anxious", recorded_at: "2025-08-03T14:30:00.000Z" },
  { id: "bulk_sync_test_3", mood: "calm", recorded_at: "2025-08-04T09:15:00.000Z" }
]

params = { mood_histories: updated_mood_histories }
controller.params = ActionController::Parameters.new(params)

# Call the sync method again
controller.sync

# Display the result
render_options = controller.instance_variable_get(:@render_options)
if render_options
  puts "Response status: #{render_options[:status]}"
  
  # Check if all records were updated
  client_ids = updated_mood_histories.map { |mh| mh[:id] }
  updated_records = user.mood_histories.where(client_id: client_ids)
  
  puts "Records updated: #{updated_records.count} of #{updated_mood_histories.count}"
  
  updated_records.each do |record|
    puts "\nUpdated record details:"
    puts "ID: #{record.id}"
    puts "Client ID: #{record.client_id}"
    puts "Mood: #{record.mood}"
    puts "Recorded at: #{record.recorded_at}"
  end
else
  puts "Error: No response from controller"
end

# Clean up test data
user.mood_histories.where(client_id: mood_histories.map { |mh| mh[:id] }).destroy_all
puts "\nTest data cleaned up"

puts "\nTest completed!"