require "rails_helper"

RSpec.describe "Authentication", type: :request do
  it "redirects an unauthenticated user to sign in" do
    get opportunities_path

    expect(response).to redirect_to(new_user_session_path)
  end

  it "allows an authenticated user to sign out" do
    user = create_user(name: "Sign Out User", email: "sign-out@example.com")
    organization = create_organization(name: "Sign Out Org")
    add_membership(user: user, organization: organization)
    sign_in user

    delete destroy_user_session_path

    expect(response).to redirect_to(root_path)
    get opportunities_path
    expect(response).to redirect_to(new_user_session_path)
  end
end
