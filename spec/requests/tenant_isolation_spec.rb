require "rails_helper"

RSpec.describe "Tenant isolation", type: :request do
  it "prevents an admin from reading or updating another organization's opportunity" do
    admin = create_user(name: "Tenant Admin", email: "tenant-admin@example.com")
    first_org = create_organization(name: "Admin Tenant Org")
    second_org = create_organization(name: "Other Tenant Org")
    add_membership(user: admin, organization: first_org, role: :admin)
    first_company = create_company(organization: first_org, name: "First Tenant Company")
    second_company = create_company(organization: second_org, name: "Second Tenant Company")
    foreign_opportunity = create_opportunity(organization: second_org, company: second_company, title: "Private Foreign Opportunity")
    sign_in admin

    get opportunity_path(foreign_opportunity)
    expect(response).to redirect_to(opportunities_path)

    patch opportunity_path(foreign_opportunity), params: {
      opportunity: {
        title: "Tampered Opportunity",
        company_id: first_company.id,
        organization_id: first_org.id
      }
    }
    expect(response).to redirect_to(opportunities_path)
    expect(foreign_opportunity.reload.title).to eq("Private Foreign Opportunity")
  end

  it "rejects creating an opportunity with a company from another organization" do
    admin = create_user(name: "Create Admin", email: "create-admin@example.com")
    first_org = create_organization(name: "Create Tenant Org")
    second_org = create_organization(name: "Foreign Company Org")
    add_membership(user: admin, organization: first_org, role: :admin)
    foreign_company = create_company(organization: second_org)
    sign_in admin

    expect do
      post opportunities_path, params: {
        opportunity: {
          company_id: foreign_company.id,
          title: "Invalid Cross Tenant Opportunity",
          estimated_value: 100,
          stage: "lead"
        }
      }
    end.not_to change(Opportunity, :count)
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "prevents sales from accessing another sales user's opportunity" do
    organization = create_organization(name: "Sales Access Org")
    first_sales = create_user(name: "First Sales", email: "first-sales@example.com")
    second_sales = create_user(name: "Second Sales", email: "second-sales@example.com")
    add_membership(user: first_sales, organization: organization, role: :sales)
    add_membership(user: second_sales, organization: organization, role: :sales)
    company = create_company(organization: organization)
    opportunity = create_opportunity(organization: organization, company: company)
    opportunity.users << second_sales
    sign_in first_sales

    get opportunity_path(opportunity)

    expect(response).to redirect_to(root_path)
  end

  it "allows an admin to read and update records in the active organization" do
    admin = create_user(name: "Positive Admin", email: "positive-admin@example.com")
    organization = create_organization(name: "Positive Admin Org")
    add_membership(user: admin, organization: organization, role: :admin)
    company = create_company(organization: organization)
    opportunity = create_opportunity(organization: organization, company: company, title: "Original Title")
    sign_in admin

    get opportunity_path(opportunity)
    expect(response).to have_http_status(:ok)

    patch opportunity_path(opportunity), params: {
      opportunity: { title: "Updated By Admin", company_id: company.id }
    }
    expect(response).to redirect_to(opportunity_path(opportunity))
    expect(opportunity.reload.title).to eq("Updated By Admin")
  end

  it "does not allow sales to assign another user through a forged request" do
    organization = create_organization(name: "Forged Assignment Org")
    sales = create_user(name: "Request Sales", email: "request-sales@example.com")
    other_sales = create_user(name: "Other Request Sales", email: "other-request-sales@example.com")
    add_membership(user: sales, organization: organization, role: :sales)
    add_membership(user: other_sales, organization: organization, role: :sales)
    company = create_company(organization: organization)
    opportunity = create_opportunity(organization: organization, company: company)
    sign_in sales

    patch opportunity_path(opportunity), params: {
      opportunity: { title: "Forged Assignment", user_ids: [other_sales.id] }
    }

    expect(response).to redirect_to(root_path)
    expect(opportunity.reload.users).to be_empty
  end
end
