class OpportunitiesController < ApplicationController
  before_action :set_opportunity, only: %i[show edit update]
  before_action :set_search_company, only: %i[new edit create update]
  before_action :set_sales_members, only: %i[new edit create update]
  authorize_resource

  def index
    @q = current_organization.opportunities
                             .accessible_by(current_ability)
                             .ransack(params[:q])
    
    @opportunities = @q.result(distinct: true)
                       .order(:title)
                       .page(params[:page])
                       .per(10)
    @summary = @q.result(distinct: true).group(:stage).pluck(
      :stage,
      Arel.sql('COUNT(DISTINCT opportunities.id)'),
      Arel.sql('COALESCE(SUM(opportunities.estimated_value), 0)')
    ).to_h do |stage, count, total|
      stage_name = Opportunity.stages.key(stage) || stage.to_s
      [stage_name, { count: count, total: total }]
    end
                       
    @current_organization = current_organization
  end

  def show
  end

  def new
    @opportunity = current_organization.opportunities.new
  end

  def create
    @opportunity = current_organization.opportunities.new(opportunity_params)

    if @opportunity.save
      redirect_to @opportunity, notice: "Opportunity was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @opportunity.update(opportunity_params)
      redirect_to @opportunity, notice: "Opportunity was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_opportunity
    @opportunity = current_organization.opportunities.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to opportunities_path, alert: "Opportunity not found or not accessible"
  end

  def set_search_company
    @companies = current_organization.companies
                                     .accessible_by(current_ability)
                                     .order(:name)
  end

  def set_sales_members
    @sales_members = sales_members
  end

  def opportunity_params
    permitted = [:title, :estimated_value, :stage, :company_id]

    permitted << { user_ids: [] } if current_user_membership&.admin?

    params.require(:opportunity).permit(permitted)
  end
end