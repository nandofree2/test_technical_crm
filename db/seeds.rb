users_data = [
  { name: 'Test User A', email: 'a@test.com' },
  { name: 'Test User B', email: 'b@test.com' },
  { name: 'Test User C', email: 'c@test.com' },
  { name: 'Test User D', email: 'd@test.com' },
  { name: 'Test User E', email: 'e@test.com' },
  { name: 'Test User F', email: 'f@test.com' },
  { name: 'Test User G', email: 'g@test.com' },
  { name: 'Test User H', email: 'h@test.com' },
  { name: 'Test User I', email: 'i@test.com' },
  { name: 'Test User J', email: 'j@test.com' },
]

users_data.each do |u_data|
  User.find_or_create_by!(email: u_data[:email]) do |user|
    user.name = u_data[:name]
    user.password = '12341234'
    user.password_confirmation = '12341234'
    puts "Users created: #{user.name} - #{user.email} - #{user.password}"
  end
end
puts "----------------------------------------------------"
puts "Users created: #{User.count}"
puts "----------------------------------------------------"