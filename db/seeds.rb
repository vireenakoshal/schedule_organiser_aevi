# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.destroy_all

# Create user
user = User.create!(
  email: "test@test.com",
  password: "password",
  password_confirmation: "password"
)

# Create schedule
schedule = user.schedules.create!(
  date: Date.today,
)

# Create tasks
schedule.tasks.create!(
  category: "Morning Run",
  duration_min: 45,
  fixed_time: "07:00",
  preferred_time: nil
)

schedule.tasks.create!(
  category: "Study Session",
  duration_min: 90,
  fixed_time: nil,
  preferred_time: "10:00"
)
