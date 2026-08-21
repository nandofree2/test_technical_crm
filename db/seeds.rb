users_data = [
  { name: 'Admin A', email: 'admin_a@test.com' },
  { name: 'Admin B', email: 'admin_b@test.com' },
  { name: 'Admin C', email: 'admin_c@test.com' },
  { name: 'Admin D', email: 'admin_d@test.com' },
  { name: 'Sales A', email: 'sales_a@test.com' },
  { name: 'Sales B', email: 'sales_b@test.com' },
  { name: 'Sales C', email: 'sales_c@test.com' },
  { name: 'Sales D', email: 'sales_d@test.com' }
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

organization = []
organization_user = []
organization[0] = Organization.find_or_create_by!(name: "PT Akalin Aja", slug: "pt-akalin-aja")
organization[1] = Organization.find_or_create_by!(name: "CV Bandung Membara", slug: "cv-bandung-membara")
organization[2] = Organization.find_or_create_by!(name: "PT Cipta Mandiri", slug: "pt-cipta-mandiri")

organization_user[0] = [
  {  email: 'admin_a@test.com', role: 'admin', member_status: 'active' },
  {  email: 'admin_b@test.com', role: 'admin', member_status: 'active' },
  {  email: 'sales_a@test.com', role: 'sales', member_status: 'active' },
  {  email: 'sales_b@test.com', role: 'sales', member_status: 'active' },
]

organization_user[1] = [
  {  email: 'admin_a@test.com', role: 'admin', member_status: 'inactive' },
  {  email: 'sales_c@test.com', role: 'sales', member_status: 'inactive' },
  {  email: 'sales_d@test.com', role: 'sales', member_status: 'active' },
]
organization_user[2] = [
  {  email: 'admin_c@test.com', role: 'admin', member_status: 'active' },
  {  email: 'sales_c@test.com', role: 'sales', member_status: 'active' }
]
organization.each_with_index do |org, index|
  puts "----------------------------------------------------"
  puts "Organization created: #{org.name} - #{org.slug}"
  puts "----------------------------------------------------"
  organization_user[index].each do |data|
    user = User.find_by(email: data[:email])
    Membership.find_or_create_by!(user: user, organization: org, role: data[:role], member_status: data[:member_status])
    puts "Membership created: #{user.name} - #{data[:role]} - #{data[:member_status]}"
  end
end

puts "Memberships created: #{Membership.count}"
puts "----------------------------------------------------"
