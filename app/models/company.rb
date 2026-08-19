class Company < ApplicationRecord
  belongs_to :organization
  has_many :assign_sales_companies, dependent: :destroy
  has_many :users, through: :assign_sales_companies

  validates :organization_id, uniqueness: { scope: :name }
end
