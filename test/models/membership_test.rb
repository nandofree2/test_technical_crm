require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  test "a user cannot have duplicate membership in one organization" do
    user = create_user(name: "Member", email: "member@example.com")
    organization = create_organization(name: "Duplicate Membership Org")
    add_membership(user: user, organization: organization)

    duplicate = Membership.new(user: user, organization: organization, role: :sales, member_status: :inactive)

    assert_not duplicate.valid?
    assert duplicate.errors.added?(:user_id, :taken)
  end

  test "a user cannot have two active memberships" do
    user = create_user(name: "Active Member", email: "active@example.com")
    first_org = create_organization(name: "First Active Org")
    second_org = create_organization(name: "Second Active Org")
    add_membership(user: user, organization: first_org)

    second_membership = Membership.new(user: user, organization: second_org, role: :sales, member_status: :active)

    assert_not second_membership.valid?
    assert_includes second_membership.errors.full_messages, "User can only have one active membership at a time"
  end
end
