#!/usr/bin/env ruby
# Run this script with: rails runner test/scripts/test_mood_sync.rb

# Test: Simulate a client-side sync request
puts "Test: Simulating a client-side sync request"

# Get the first user for testing
user = User.first
if user.nil?
  puts "Error: No users found in the database"
  exit 1
end

# Create a controller instance for testing
controller = MoodHistoriesController.new
controller.instance_variable_set(:@_current_user, user)

# Simulate params for the sync request
client_id = "1754490141475kve90f9gq"
mood = "neutral"
recorded_at = "2025-08-01T00:00:00.000Z"

# First request - should create a new record
puts "\nFirst sync request (create):"
params = { id: client_id, mood: mood, recorded_at: recorded_at }
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
  
  # Find the created record
  mood_history = user.mood_histories.find_by(client_id: client_id)
  if mood_history
    puts "Record created successfully:"
    puts "ID: #{mood_history.id}"
    puts "Client ID: #{mood_history.client_id}"
    puts "Mood: #{mood_history.mood}"
    puts "Recorded at: #{mood_history.recorded_at}"
  else
    puts "Error: Record not created"
  end
else
  puts "Error: No response from controller"
end

# Second request with the same client_id but different mood - should update
puts "\nSecond sync request (update):"
params = { id: client_id, mood: "happy", recorded_at: recorded_at }
controller.params = ActionController::Parameters.new(params)

# Call the sync method again
controller.sync

# Display the result
render_options = controller.instance_variable_get(:@render_options)
if render_options
  puts "Response status: #{render_options[:status]}"
  
  # Find the updated record
  mood_history = user.mood_histories.find_by(client_id: client_id)
  if mood_history && mood_history.mood == "happy"
    puts "Record updated successfully:"
    puts "ID: #{mood_history.id}"
    puts "Client ID: #{mood_history.client_id}"
    puts "Mood: #{mood_history.mood}"
    puts "Recorded at: #{mood_history.recorded_at}"
  else
    puts "Error: Record not updated correctly"
  end
else
  puts "Error: No response from controller"
end

puts "\nTest completed!"