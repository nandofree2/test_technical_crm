class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization
  enum role: { sales: 0, admin: 1 }
  enum member_status: { active: 0, inactive: 1 }

  validates :user_id, uniqueness: { scope: :organization_id }
  validate :only_active_membership_per_user, if: :active?

  private

  def only_active_membership_per_user
    errors.add(:base, "User can only have one active membership at a time") if user.memberships.active.where.not(id: id).exists?
  end
end
