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
  { name: 'Test User J', email: 'j@test.com' }
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
org_a = Organization.find_or_create_by!(name: "PT Akalin Aja", slug: "pt-akalin-aja")
org_b = Organization.find_or_create_by!(name: "CV Bandung Membara", slug: "cv-bandung-membara")
org_c = Organization.find_or_create_by!(name: "PT Cipta Mandiri", slug: "pt-cipta-mandiri")

org_a_admin = [
  {  email: 'a@test.com', role: 'admin', member_status: 'active' },
  {  email: 'b@test.com', role: 'admin', member_status: 'active' },
  {  email: 'c@test.com', role: 'sales', member_status: 'active' },
  {  email: 'd@test.com', role: 'sales', member_status: 'active' },
  {  email: 'e@test.com', role: 'sales', member_status: 'active' }
]

org_b_admin = [
  {  email: 'a@test.com', role: 'admin', member_status: 'inactive' },
  {  email: 'f@test.com', role: 'admin', member_status: 'active' },
  {  email: 'g@test.com', role: 'sales', member_status: 'active' },
  {  email: 'h@test.com', role: 'sales', member_status: 'active' },
]
org_c_admin = [
  {  email: 'i@test.com', role: 'admin', member_status: 'active' },
  {  email: 'j@test.com', role: 'sales', member_status: 'active' }
]

org_a_admin.each do |admin_data|
  user = User.find_by(email: admin_data[:email])
  Membership.find_or_create_by!(user: user, organization: org_a, role: admin_data[:role], member_status: admin_data[:member_status])
end

org_b_admin.each do |admin_data|
  user = User.find_by(email: admin_data[:email])
  Membership.find_or_create_by!(user: user, organization: org_b, role: admin_data[:role], member_status: admin_data[:member_status])
end

org_c_admin.each do |admin_data|
  user = User.find_by(email: admin_data[:email])
  Membership.find_or_create_by!(user: user, organization: org_c, role: admin_data[:role], member_status: admin_data[:member_status])
end

puts "Memberships created: #{Membership.count}"
puts "----------------------------------------------------"
