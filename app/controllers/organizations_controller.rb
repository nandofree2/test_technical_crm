class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[ show ]
  authorize_resource

  def index
    @organizations = Organization.accessible_by(current_ability)
  end

  def show
    @memberships = @organization.memberships.includes(:user)

    if current_user_membership&.sales?
      @companies = @organization.companies.joins(:assign_sales_companies).where(assign_sales_companies: { user_id: current_user.id })
    elsif current_user_membership&.admin?
      @companies = @organization.companies
    end
  end


  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def organization_params
    params.require(:organization).permit(:name, :slug)
  end
end
