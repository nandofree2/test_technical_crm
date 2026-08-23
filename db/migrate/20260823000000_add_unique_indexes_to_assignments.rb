class AddUniqueIndexesToAssignments < ActiveRecord::Migration[7.2]
  def change
    add_index :assign_sales_companies, [:user_id, :company_id], unique: true,
              name: "index_assign_sales_companies_on_user_and_company_unique"
    add_index :assign_sales_opportunities, [:user_id, :opportunity_id], unique: true,
              name: "index_assign_sales_opportunities_on_user_and_opportunity_unique"
  end
end
