module MembershipOperation
  class SwitchService
    attr_reader :error_message

    def initialize(user, membership_id)
      @user = user
      @membership_id = membership_id
      @error_message = nil
    end

    def switch
      target_membership = @user.memberships.find_by(id: @membership_id)

      unless target_membership
        @error_message = "You are not a member of the selected organization"
        return false
      end

      ActiveRecord::Base.transaction do
        current_active = @user.memberships.active.first
        current_active.inactive! if current_active && current_active != target_membership

        target_membership.active!
      end

      true
    rescue => e
      Rails.logger.error("Membership switch failed: #{e.message}")
      @error_message = "Failed to update organization: #{e.message}"
      false
    end
  end
end