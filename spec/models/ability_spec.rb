require "rails_helper"

RSpec.describe Ability, type: :model do
  it "allows an admin to manage records in the active organization only" do
    admin = create_user(name: "Ability Admin", email: "ability-admin@example.com")
    organization = create_organization(name: "Ability Admin Org")
    foreign_organization = create_organization(name: "Ability Foreign Org")
    add_membership(user: admin, organization: organization, role: :admin)
    company = create_company(organization: organization)
    foreign_company = create_company(organization: foreign_organization)

    ability = described_class.new(admin)

    expect(ability.can?(:manage, company)).to be(true)
    expect(ability.can?(:manage, foreign_company)).to be(false)
  end

  it "allows sales to manage only assigned records" do
    sales = create_user(name: "Ability Sales", email: "ability-sales@example.com")
    organization = create_organization(name: "Ability Sales Org")
    add_membership(user: sales, organization: organization, role: :sales)
    assigned_company = create_company(organization: organization, name: "Assigned Ability Company")
    unassigned_company = create_company(organization: organization, name: "Unassigned Ability Company")
    assigned_company.users << sales
    assigned_opportunity = create_opportunity(organization: organization, company: assigned_company)
    assigned_opportunity.users << sales
    unassigned_opportunity = create_opportunity(organization: organization, company: unassigned_company, title: "Unassigned Ability Opportunity")

    ability = described_class.new(sales)

    expect(ability.can?(:read, assigned_company)).to be(true)
    expect(ability.can?(:read, unassigned_company)).to be(false)
    expect(ability.can?(:update, assigned_opportunity)).to be(true)
    expect(ability.can?(:update, unassigned_opportunity)).to be(false)
    expect(ability.can?(:create, Opportunity.new(organization: organization))).to be(false)
  end
end
