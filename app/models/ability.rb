class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    active_membership = user.memberships.active.first

    can :manage, Company, organization_id: active_membership.organization_id if active_membership&.admin?
    can :read, :update, Company, organization_id: active_membership.organization_id if active_membership&.sales?

  end
end
