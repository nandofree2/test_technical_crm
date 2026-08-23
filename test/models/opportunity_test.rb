require "test_helper"

class OpportunityTest < ActiveSupport::TestCase
  test "rejects a company from another organization" do
    first_org = create_organization(name: "Opportunity Org")
    second_org = create_organization(name: "Company Org")
    company = create_company(organization: second_org)

    opportunity = Opportunity.new(
      organization: first_org,
      company: company,
      title: "Cross Tenant Opportunity",
      estimated_value: 100,
      stage: :lead
    )

    assert_not opportunity.valid?
    assert_includes opportunity.errors.full_messages, "Company must belong to this organization"
  end

  test "rejects an assigned user who is not an active organization member" do
    organization = create_organization(name: "Assignment Org")
    company = create_company(organization: organization)
    user = create_user(name: "External User", email: "external@example.com")
    opportunity = create_opportunity(organization: organization, company: company)
    opportunity.users << user

    assert_not opportunity.valid?
    assert_includes opportunity.errors.full_messages, "Users must be active members of this organization"
  end

  test "does not allow negative estimated value" do
    organization = create_organization(name: "Value Org")
    company = create_company(organization: organization)

    opportunity = Opportunity.new(
      organization: organization,
      company: company,
      title: "Negative Value",
      estimated_value: -1,
      stage: :lead
    )

    assert_not opportunity.valid?
    assert_includes opportunity.errors.full_messages, "Estimated value must be greater than or equal to 0"
  end
end
