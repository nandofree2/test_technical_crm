class Opportunity < ApplicationRecord
  belongs_to :company
  belongs_to :organization
  has_many :assign_sales_opportunities, dependent: :destroy
  has_many :users, through: :assign_sales_opportunities
  enum stage: { lead: 0, proposal: 1, won: 2, lost: 3 }
  
  attr_accessor :company_search

  validates :title, presence: true
  validates :estimated_value, numericality: { greater_than_or_equal_to: 0 }
  validate :company_must_belong_to_organization
  validate :assigned_sales_users_must_belong_to_organization

  def self.ransackable_attributes(auth_object = nil)
    ["title", "estimated_value", "stage", "company_id", "organization_id", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["assign_sales_opportunities", "company", "organization", "users"]
  end

  def assigned_sales_users_must_belong_to_organization
    return if users.blank?

    invalid_users = users.select do |user|
      !Membership.exists?(
        organization_id: organization_id,
        user_id: user.id,
        member_status: :active
      )
    end

    if invalid_users.any?
      errors.add(:users, "must be active members of this organization")
    end
  end

  def company_must_belong_to_organization
    return if company.blank? || organization_id.blank?
    return if company.organization_id == organization_id

    errors.add(:company, "must belong to this organization")
  end
end
