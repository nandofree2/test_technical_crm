class Opportunity < ActiveRecord::Migration[7.2]
  def change
    create_table :opportunities, id: :uuid do |t|
      t.references :organization, type: :uuid, null: false, foreign_key: true
      t.references :company, type: :uuid, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :stage, default: 0, null: false
      t.integer :estimated_value, default: 0, null: false
      t.timestamps
    end
    add_index :opportunities, [ :company_id, :title ]
  end
end
