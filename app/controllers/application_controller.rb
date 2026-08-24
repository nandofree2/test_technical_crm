class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  include CanCan::ControllerAdditions

  helper_method :current_organization, :current_user_membership, :sales_members

  private

  def current_organization
    return nil unless current_user
    current_user.memberships.active.first&.organization
  end

  def sales_members
    return Membership.none unless current_organization

    current_organization.memberships.active.where(role: :sales).includes(:user)
  end

  def current_user_membership
    return nil unless current_user
    current_user.memberships.active.first
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        redirect_to root_path, alert: "You do not have access for this action."
      end
      format.json do
        render json: { error: "You do not have access for this action." }, status: :forbidden
      end
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
