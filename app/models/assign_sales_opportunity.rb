class AssignSalesOpportunity < ApplicationRecord
  belongs_to :opportunity
  belongs_to :user
end
