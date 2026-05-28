# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "destroying user..."
User.destroy_all
puts "creating user..."

user = User.create!(email: 'alex@example.com', password: '123123')

puts "creating schedule..."

schedule_1 = Schedule.find_or_create_by!(date: Date.today, user: user)
schedule_2 = Schedule.find_or_create_by!(date: Date.tomorrow, user: user)
schedule_3 = Schedule.find_or_create_by!(date: Date.yesterday, user: user)

puts "creating task..."

[schedule_1, schedule_2, schedule_3].each do |schedule|
  Task.create!(category: 'work', duration_min: 60, fixed_time: "8:00", preferred_time: "10:00", schedule: schedule, title: "work")
  Task.create!(category: 'free time', duration_min: 90, fixed_time: "18:00", preferred_time: "20:00", schedule: schedule, title: "free")
  Task.create!(category: 'go for a walk', duration_min: 120, fixed_time: "19:00", preferred_time: "2:00", schedule: schedule, title: "activity")
  Task.create!(category: 'eat cookies', duration_min: 30, fixed_time: "21:00", preferred_time: "4:00", schedule: schedule, title: "eat snacks")
end

puts "Finished!"
