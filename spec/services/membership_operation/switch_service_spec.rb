require "rails_helper"

RSpec.describe MembershipOperation::SwitchService, type: :service do
  it "cannot switch to an organization without membership" do
    user = create_user(name: "Switcher", email: "switcher@example.com")
    current_org = create_organization(name: "Current Switch Org")
    unrelated_org = create_organization(name: "Unrelated Switch Org")
    current_membership = add_membership(user: user, organization: current_org)

    result = described_class.new(user, unrelated_org.id).switch

    expect(result).to be(false)
    expect(current_membership.reload.member_status).to eq("active")
  end
end
