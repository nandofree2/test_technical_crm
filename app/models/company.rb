class Company < ApplicationRecord
  belongs_to :organization
  has_many :assign_sales_companies, dependent: :destroy
  has_many :users, through: :assign_sales_companies

  validates :organization_id, uniqueness: { scope: :name }
  validate :assigned_sales_users_must_belong_to_organization

  def self.ransackable_attributes(auth_object = nil)
    ["name", "industry", "organization_id", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["assign_sales_companies", "organization", "users"]
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
end
