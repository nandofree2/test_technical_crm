require "test_helper"

class MembershipOperation::SwitchServiceTest < ActiveSupport::TestCase
  test "cannot switch to an organization without membership" do
    user = create_user(name: "Switcher", email: "switcher@example.com")
    current_org = create_organization(name: "Current Switch Org")
    unrelated_org = create_organization(name: "Unrelated Switch Org")
    current_membership = add_membership(user: user, organization: current_org)
    unrelated_membership = add_membership(
      user: user,
      organization: unrelated_org,
      role: :sales,
      member_status: :inactive
    )

    result = MembershipOperation::SwitchService.new(user, unrelated_membership.id).switch

    assert_not result
    assert_equal current_membership.reload.member_status, "active"
    assert_equal "inactive", unrelated_membership.reload.member_status
  end
end
