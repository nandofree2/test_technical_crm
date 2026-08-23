require "rails_helper"

RSpec.describe "Opportunity authorization", type: :request do
  it "allows sales to update an assigned opportunity" do
    organization = create_organization(name: "Assigned Opportunity Organizastion")
    sales = create_user(name: "Assigned Opportunity Sales", email: "assigned-opportunity-sales@example.com")
    add_membership(user: sales, organization: organization, role: :sales)
    company = create_company(organization: organization)
    opportunity = create_opportunity(organization: organization, company: company, title: "Sales Title")
    opportunity.users << sales
    sign_in sales

    patch opportunity_path(opportunity), params: {
      opportunity: { title: "Updated Sales Title", company_id: company.id }
    }

    expect(response).to redirect_to(opportunity_path(opportunity))
    expect(opportunity.reload.title).to eq("Updated Sales Title")
  end

  it "does not allow sales to update an unassigned opportunity" do
    organization = create_organization(name: "Unassigned Opportunity Organization")
    sales = create_user(name: "Unassigned Opportunity Sales", email: "unassigned-opportunity-sales@example.com")
    add_membership(user: sales, organization: organization, role: :sales)
    company = create_company(organization: organization)
    opportunity = create_opportunity(organization: organization, company: company, title: "Protected Title")
    sign_in sales

    patch opportunity_path(opportunity), params: {
      opportunity: { title: "Unauthorized Title", company_id: company.id }
    }

    expect(response).to redirect_to(root_path)
    expect(opportunity.reload.title).to eq("Protected Title")
  end

  it "does not allow an admin to create an opportunity without a company" do
    admin = create_user(name: "No Company Admin", email: "no-company-admin@example.com")
    organization = create_organization(name: "Required Company Organization")
    add_membership(user: admin, organization: organization, role: :admin)
    sign_in admin

    expect do
      post opportunities_path, params: {
        opportunity: { title: "Missing Company", estimated_value: 10, stage: "lead" }
      }
    end.not_to change(Opportunity, :count)
    expect(response).to have_http_status(:unprocessable_entity)
  end
end
