class CompaniesController < ApplicationController
  before_action :set_company, only: %i[show edit update destroy]

  def index
    @q = current_organization.companies.ransack(params[:q])
    @companies = @q.result(distinct: true).order(:name).page(params[:page]).per(10)
    @current_organization = current_organization
  end

  def show
  end

  def new
    @company = current_organization.companies.new
    authorize! :create, @company
  end

  def create
    @company = current_organization.companies.new(company_params)
    authorize! :create, @company

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

  def destroy
    @company.destroy
    redirect_to companies_path, notice: "Company was successfully destroyed.", status: :see_other
  end

  private

  def set_company
    org = current_organization
    @company = org.companies.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to companies_path, alert: "Company not found or not accessible"
  end

  def company_params
    params.require(:company).permit(:name, :industry)
  end
end
