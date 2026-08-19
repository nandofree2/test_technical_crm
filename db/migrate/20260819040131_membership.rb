class Membership < ActiveRecord::Migration[7.2]
  def change
    create_table :memberships, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :organization, type: :uuid, null: false, foreign_key: true
      t.integer :role, default: 0, null: false
      t.timestamps
    end

    add_index :memberships, [ :user_id, :organization_id ], unique: true
  end
end
