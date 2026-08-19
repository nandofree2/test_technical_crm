class CreateCompany < ActiveRecord::Migration[7.2]
  def change
    create_table :companies, id: :uuid do |t|
      t.references :organization, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.string :industry
      t.timestamps
    end
    add_index :companies, [ :organization_id, :name ]
  end
end
