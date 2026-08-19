class Opportunity < ApplicationRecord
  belongs_to :company
  belongs_to :organization
  has_many :assign_sales_opportunities, dependent: :destroy
  has_many :users, through: :assign_sales_opportunities
  enum stage: { lead: 0, proposal: 1, won: 2, lost: 3 }
end
