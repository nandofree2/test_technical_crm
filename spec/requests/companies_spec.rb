require "rails_helper"

RSpec.describe "Companies", type: :request do
  it "allows an admin to create and update a company in the active organization" do
    admin = create_user(name: "Company Admin", email: "company-admin@example.com")
    organization = create_organization(name: "Company CRUD Org")
    add_membership(user: admin, organization: organization, role: :admin)
    sign_in admin

    expect do
      post companies_path, params: {
        company: { name: "Created Company", industry: "Finance" }
      }
    end.to change(Company, :count).by(1)

    company = Company.order(:created_at).last
    expect(company.organization_id).to eq(organization.id)
    expect(response).to redirect_to(company_path(company))

    patch company_path(company), params: {
      company: { name: "Updated Company", industry: "Technology" }
    }
    expect(response).to redirect_to(company_path(company))
    expect(company.reload.name).to eq("Updated Company")
  end

  it "prevents sales from reading or updating an unassigned company" do
    organization = create_organization(name: "Sales Company Access Org")
    sales = create_user(name: "Company Sales", email: "company-sales@example.com")
    add_membership(user: sales, organization: organization, role: :sales)
    company = create_company(organization: organization)
    sign_in sales

    get company_path(company)
    expect(response).to redirect_to(root_path)

    patch company_path(company), params: { company: { name: "Unauthorized Update" } }
    expect(response).to redirect_to(root_path)
    expect(company.reload.name).to eq("Example Company")
  end

  it "allows sales to read and update an assigned company" do
    organization = create_organization(name: "Assigned Company Access Org")
    sales = create_user(name: "Assigned Company Sales", email: "assigned-company-sales@example.com")
    add_membership(user: sales, organization: organization, role: :sales)
    company = create_company(organization: organization)
    company.users << sales
    sign_in sales

    get company_path(company)
    expect(response).to have_http_status(:ok)

    patch company_path(company), params: { company: { name: "Updated Assigned Company" } }
    expect(response).to redirect_to(company_path(company))
    expect(company.reload.name).to eq("Updated Assigned Company")
  end

  it "does not expose a company from another organization by ID" do
    sales = create_user(name: "Scoped Company Sales", email: "scoped-company-sales@example.com")
    organization = create_organization(name: "Scoped Company Org")
    foreign_organization = create_organization(name: "Foreign Scoped Company Org")
    add_membership(user: sales, organization: organization, role: :sales)
    foreign_company = create_company(organization: foreign_organization)
    sign_in sales

    get company_path(foreign_company)

    expect(response).to redirect_to(companies_path)
  end
end
