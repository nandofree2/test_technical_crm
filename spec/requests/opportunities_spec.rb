require "rails_helper"

RSpec.describe "Opportunities", type: :request do
  it "creates an opportunity in the active organization" do
    admin = create_user(name: "Form Admin", email: "form-admin@example.com")
    organization = create_organization(name: "Form Org")
    other_organization = create_organization(name: "Forged Org")
    add_membership(user: admin, organization: organization, role: :admin)
    company = create_company(organization: organization)
    sign_in admin

    expect do
      post opportunities_path, params: {
        opportunity: {
          company_id: company.id,
          organization_id: other_organization.id,
          title: "Trusted Tenant Opportunity",
          estimated_value: 250,
          stage: "proposal"
        }
      }
    end.to change(Opportunity, :count).by(1)

    opportunity = Opportunity.order(:created_at).last
    expect(opportunity.organization_id).to eq(organization.id)
    expect(response).to redirect_to(opportunity_path(opportunity))
  end

  it "scopes company search, stage filtering, and summary to the active organization" do
    admin = create_user(name: "Report Admin", email: "report-admin@example.com")
    organization = create_organization(name: "Reporting Org")
    other_organization = create_organization(name: "Hidden Reporting Org")
    add_membership(user: admin, organization: organization, role: :admin)
    company = create_company(organization: organization, name: "Searchable Company")
    other_company = create_company(organization: other_organization, name: "Hidden Company")
    create_opportunity(organization: organization, company: company, title: "Proposal Opportunity", estimated_value: 300, stage: :proposal)
    create_opportunity(organization: organization, company: company, title: "Lead Opportunity", estimated_value: 100, stage: :lead)
    create_opportunity(organization: other_organization, company: other_company, title: "Hidden Opportunity", estimated_value: 900, stage: :proposal)
    sign_in admin

    get companies_path, params: { q: { name_cont: "Searchable" } }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Searchable Company")
    expect(response.body).not_to include("Hidden Company")

    get opportunities_path, params: { q: { stage_eq: Opportunity.stages[:proposal] } }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Proposal Opportunity")
    expect(response.body).not_to include("Lead Opportunity")
    expect(response.body).not_to include("Hidden Opportunity")
    expect(response.body).to match(/<h4[^>]*>\s*1\s*<small[^>]*>items<\/small>/)
    expect(response.body).to include("Rp 300")
  end
end
