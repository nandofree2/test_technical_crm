ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "devise/test/integration_helpers"

class ActiveSupport::TestCase
  parallelize(workers: 1)
  self.use_transactional_tests = true

  def create_user(name:, email:)
    User.create!(
      name: name,
      email: email,
      password: "password123",
      password_confirmation: "password123"
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

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def sign_in_as(user)
    sign_in user
  end
end
