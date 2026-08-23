require "rails_helper"

RSpec.describe "Organization switching", type: :request do
  it "does not switch to an organization without membership" do
    user = create_user(name: "Switcher", email: "request-switcher@example.com")
    organization = create_organization(name: "Member Organization")
    unrelated = create_organization(name: "Unrelated Organization")
    add_membership(user: user, organization: organization)
    sign_in user

    post switch_organization_user_path(user), params: { membership_id: unrelated.id }

    expect(response).to have_http_status(:forbidden)
    expect(user.memberships.active.first.organization_id).to eq(organization.id)
  end
end
