require "rails_helper"

RSpec.describe Membership, type: :model do
  it "does not allow duplicate membership in one organization" do
    user = create_user(name: "Member", email: "member@example.com")
    organization = create_organization(name: "Duplicate Membership Org")
    add_membership(user: user, organization: organization)

    duplicate = described_class.new(user: user, organization: organization, role: :sales, member_status: :inactive)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:user_id]).to include("has already been taken")
  end

  it "does not allow a user to have two active memberships" do
    user = create_user(name: "Active Member", email: "active@example.com")
    first_org = create_organization(name: "First Active Org")
    second_org = create_organization(name: "Second Active Org")
    add_membership(user: user, organization: first_org)

    second_membership = described_class.new(user: user, organization: second_org, role: :sales, member_status: :active)

    expect(second_membership).not_to be_valid
    expect(second_membership.errors.full_messages).to include("User can only have one active membership at a time")
  end

  it "allows multiple users in the same organization" do
    organization = create_organization(name: "Multi User Org")
    first_user = create_user(name: "First User", email: "first-user@example.com")
    second_user = create_user(name: "Second User", email: "second-user@example.com")

    expect {
      add_membership(user: first_user, organization: organization, role: :sales)
      add_membership(user: second_user, organization: organization, role: :sales)
    }.not_to raise_error
  end
end
