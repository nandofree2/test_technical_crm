class Company < ApplicationRecord
  belongs_to :organization
  has_many :assign_sales_companies, dependent: :destroy
  has_many :users, through: :assign_sales_companies

  validates :organization_id, uniqueness: { scope: :name }

  def self.ransackable_attributes(auth_object = nil)
    ["name", "industry", "organization_id", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["assign_sales_companies", "organization", "users"]
  end
end
