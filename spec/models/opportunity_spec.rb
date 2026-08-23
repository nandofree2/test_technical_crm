require "rails_helper"

RSpec.describe Opportunity, type: :model do
  it "rejects a company from another organization" do
    first_org = create_organization(name: "Opportunity Org")
    second_org = create_organization(name: "Company Org")
    company = create_company(organization: second_org)

    opportunity = described_class.new(
      organization: first_org,
      company: company,
      title: "Cross Tenant Opportunity",
      estimated_value: 100,
      stage: :lead
    )

    expect(opportunity).not_to be_valid
    expect(opportunity.errors.full_messages).to include("Company must belong to this organization")
  end

  it "rejects an assigned user who is not an active organization member" do
    organization = create_organization(name: "Assignment Org")
    company = create_company(organization: organization)
    user = create_user(name: "External User", email: "external@example.com")
    opportunity = create_opportunity(organization: organization, company: company)
    opportunity.users << user

    expect(opportunity).not_to be_valid
    expect(opportunity.errors.full_messages).to include("Users must be active members of this organization")
  end

  it "does not allow negative estimated value" do
    organization = create_organization(name: "Value Org")
    company = create_company(organization: organization)
    opportunity = described_class.new(
      organization: organization,
      company: company,
      title: "Negative Value",
      estimated_value: -1,
      stage: :lead
    )

    expect(opportunity).not_to be_valid
    expect(opportunity.errors.full_messages).to include("Estimated value must be greater than or equal to 0")
  end

  it "rejects an assigned user from another organization" do
    organization = create_organization(name: "Assignment Owner Org")
    foreign_organization = create_organization(name: "Foreign Owner Org")
    company = create_company(organization: organization)
    user = create_user(name: "Foreign Sales", email: "foreign-sales@example.com")
    add_membership(user: user, organization: foreign_organization, role: :sales)
    opportunity = create_opportunity(organization: organization, company: company)
    opportunity.users << user

    expect(opportunity).not_to be_valid
    expect(opportunity.errors.full_messages).to include("Users must be active members of this organization")
  end
end
