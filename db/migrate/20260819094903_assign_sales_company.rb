class AssignSalesCompany < ActiveRecord::Migration[7.2]
  def change
    create_table :assign_sales_companies, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :company, type: :uuid, null: false, foreign_key: true
      t.timestamps
    end
    add_index :assign_sales_companies, [ :user_id, :company_id ]
  end
end
