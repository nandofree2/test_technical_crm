require "test_helper"

class OpportunitiesTest < ActionDispatch::IntegrationTest
  test "admin can create an opportunity without trusting organization_id" do
    admin = create_user(name: "Form Admin", email: "form-admin@example.com")
    organization = create_organization(name: "Form Org")
    other_organization = create_organization(name: "Forged Org")
    add_membership(user: admin, organization: organization, role: :admin)
    company = create_company(organization: organization)
    sign_in_as(admin)

    assert_difference("Opportunity.count") do
      post opportunities_path, params: {
        opportunity: {
          company_id: company.id,
          organization_id: other_organization.id,
          title: "Trusted Tenant Opportunity",
          estimated_value: 250,
          stage: "proposal"
        }
      }
    end

    opportunity = Opportunity.order(:created_at).last
    assert_equal organization.id, opportunity.organization_id
    assert_redirected_to opportunity_path(opportunity)
  end

  test "company search, stage filtering, and summary are scoped to the active organization" do
    admin = create_user(name: "Report Admin", email: "report-admin@example.com")
    organization = create_organization(name: "Reporting Org")
    other_organization = create_organization(name: "Hidden Reporting Org")
    add_membership(user: admin, organization: organization, role: :admin)
    company = create_company(organization: organization, name: "Searchable Company")
    other_company = create_company(organization: other_organization, name: "Hidden Company")
    create_opportunity(
      organization: organization,
      company: company,
      title: "Proposal Opportunity",
      estimated_value: 300,
      stage: :proposal
    )
    create_opportunity(
      organization: organization,
      company: company,
      title: "Lead Opportunity",
      estimated_value: 100,
      stage: :lead
    )
    create_opportunity(
      organization: other_organization,
      company: other_company,
      title: "Hidden Opportunity",
      estimated_value: 900,
      stage: :proposal
    )
    sign_in_as(admin)

    get companies_path, params: { q: { name_cont: "Searchable" } }
    assert_response :success
    assert_includes response.body, "Searchable Company"
    assert_not_includes response.body, "Hidden Company"

    get opportunities_path, params: { q: { stage_eq: Opportunity.stages[:proposal] } }
    assert_response :success
    assert_includes response.body, "Proposal Opportunity"
    assert_not_includes response.body, "Lead Opportunity"
    assert_not_includes response.body, "Hidden Opportunity"
    assert_includes response.body, "1 items"
    assert_includes response.body, "Rp 300"
  end
end
