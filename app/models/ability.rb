class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    active_membership = user.memberships.active.first
    return unless active_membership

    if active_membership.admin?
      can :read, Organization, id: active_membership.organization_id
      can :manage, Company, organization_id: active_membership.organization_id
      can :manage, Opportunity, organization_id: active_membership.organization_id
    elsif active_membership.sales?
      can :read, Organization, id: active_membership.organization_id
      can %i[read update], Company, organization_id: active_membership.organization_id, users: { id: user.id }
      can %i[read update], Opportunity, organization_id: active_membership.organization_id, users: { id: user.id }
    end
  end
end