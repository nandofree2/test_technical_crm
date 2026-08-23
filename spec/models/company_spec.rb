require "rails_helper"

RSpec.describe Company, type: :model do
  it "rejects an assigned user from another organization" do
    organization = create_organization(name: "Company Owner Org")
    other_organization = create_organization(name: "other Company User Org")
    company = create_company(organization: organization)
    user = create_user(name: "other Company User", email: "other-company-user@example.com")
    add_membership(user: user, organization: other_organization, role: :sales)
    company.users << user

    expect(company).not_to be_valid
    expect(company.errors.full_messages).to include("Users must be active members of this organization")
  end

  it "allows an active organization member to be assigned" do
    organization = create_organization(name: "Valid Company Assignment Org")
    company = create_company(organization: organization)
    user = create_user(name: "Valid Company User", email: "valid-company-user@example.com")
    add_membership(user: user, organization: organization, role: :sales)
    company.users << user

    expect(company).to be_valid
  end

  it "does not allow duplicate company names within one organization" do
    organization = create_organization(name: "Unique Company Org")
    create_company(organization: organization, name: "Same Company")
    duplicate = Company.new(organization: organization, name: "Same Company")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:organization_id]).to include("has already been taken")
  end
end
