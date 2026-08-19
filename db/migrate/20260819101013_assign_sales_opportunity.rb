class AssignSalesOpportunity < ActiveRecord::Migration[7.2]
  def change
    create_table :assign_sales_opportunities, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :opportunity, type: :uuid, null: false, foreign_key: true
      t.timestamps
    end
    add_index :assign_sales_opportunities, [ :user_id, :opportunity_id ]
  end
end
