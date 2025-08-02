# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding roles..."
%w[admin user].each do |role|
  Role.find_or_create_by!(name: role)
end

puts "Creating default admin user..."
admin = User.find_by!(email: 'necromancer.morgath@gmail.com')

admin.roles << Role.find_by(name: 'admin') unless admin.has_role?(:admin)

puts "Seed completed."
