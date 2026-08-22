class CompaniesController < ApplicationController
  before_action :set_company, only: %i[show edit update]
  before_action :set_sales_members, only: %i[new edit]
  authorize_resource

  def index
    @q = current_organization.companies
                             .accessible_by(current_ability)
                             .ransack(params[:q])
    
    @companies = @q.result(distinct: true)
                   .order(:name)
                   .page(params[:page])
                   .per(10)
    @current_organization = current_organization
  end

  def show
  end

  def new
    @company = current_organization.companies.new
  end

  def create
    @company = current_organization.companies.new(company_params)

    if @company.save
      redirect_to @company, notice: "Company was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @company.update(company_params)
      redirect_to @company, notice: "Company was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_company
    @company = current_organization.companies.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to companies_path, alert: "Company not found or not accessible"
  end

  def set_sales_members
    @sales_members = sales_members
  end

  def company_params
    permitted = [ :name, :industry ]
    
    permitted << { user_ids: [] } if current_user_membership&.admin?

    params.require(:company).permit(permitted)
  end
end