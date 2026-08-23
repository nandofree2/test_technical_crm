module SpecFactories
  def create_user(name:, email:)
    User.create!(
      name: name,
      email: email,
      password: "12341234",
      password_confirmation: "12341234"
    )
  end

  def create_organization(name:)
    Organization.create!(name: name, slug: name.parameterize)
  end

  def add_membership(user:, organization:, role: :sales, member_status: :active)
    Membership.create!(
      user: user,
      organization: organization,
      role: role,
      member_status: member_status
    )
  end

  def create_company(organization:, name: "Example Company")
    Company.create!(organization: organization, name: name, industry: "Technology")
  end

  def create_opportunity(organization:, company:, title: "Example Opportunity", estimated_value: 100, stage: :lead)
    Opportunity.create!(
      organization: organization,
      company: company,
      title: title,
      estimated_value: estimated_value,
      stage: stage
    )
  end
end

RSpec.configure do |config|
  config.include SpecFactories
end
