require "test_helper"

class TenantIsolationTest < ActionDispatch::IntegrationTest
  test "admin cannot read or update another organization's opportunity" do
    admin = create_user(name: "Tenant Admin", email: "tenant-admin@example.com")
    first_org = create_organization(name: "Admin Tenant Org")
    second_org = create_organization(name: "Other Tenant Org")
    add_membership(user: admin, organization: first_org, role: :admin)
    first_company = create_company(organization: first_org, name: "First Tenant Company")
    second_company = create_company(organization: second_org, name: "Second Tenant Company")
    foreign_opportunity = create_opportunity(
      organization: second_org,
      company: second_company,
      title: "Private Foreign Opportunity"
    )
    sign_in_as(admin)

    get opportunity_path(foreign_opportunity)
    assert_redirected_to opportunities_path

    patch opportunity_path(foreign_opportunity), params: {
      opportunity: {
        title: "Tampered Opportunity",
        company_id: first_company.id,
        organization_id: first_org.id
      }
    }
    assert_redirected_to opportunities_path
    assert_equal "Private Foreign Opportunity", foreign_opportunity.reload.title
  end

  test "admin cannot create an opportunity with a company from another organization" do
    admin = create_user(name: "Create Admin", email: "create-admin@example.com")
    first_org = create_organization(name: "Create Tenant Org")
    second_org = create_organization(name: "Foreign Company Org")
    add_membership(user: admin, organization: first_org, role: :admin)
    foreign_company = create_company(organization: second_org)
    sign_in_as(admin)

    assert_no_difference("Opportunity.count") do
      post opportunities_path, params: {
        opportunity: {
          company_id: foreign_company.id,
          title: "Invalid Cross Tenant Opportunity",
          estimated_value: 100,
          stage: "lead"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "sales cannot access another sales user's opportunity" do
    organization = create_organization(name: "Sales Access Org")
    first_sales = create_user(name: "First Sales", email: "first-sales@example.com")
    second_sales = create_user(name: "Second Sales", email: "second-sales@example.com")
    add_membership(user: first_sales, organization: organization, role: :sales)
    add_membership(user: second_sales, organization: organization, role: :sales)
    company = create_company(organization: organization)
    opportunity = create_opportunity(organization: organization, company: company)
    opportunity.users << second_sales
    sign_in_as(first_sales)

    get opportunity_path(opportunity)

    assert_redirected_to root_path
  end
end
