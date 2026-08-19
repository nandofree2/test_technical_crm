class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[ show edit update destroy ]

  # GET /organizations
  def index
    @organizations = Organization.order(:name)
  end

  # GET /organizations/1
  def show
    @memberships = @organization.memberships.includes(:user)
    @companies = @organization.companies
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end

  # GET /organizations/1/edit
  def edit
  end

  # POST /organizations
  def create
    @organization = Organization.new(organization_params)

    if @organization.save
      redirect_to @organization, notice: "Organization was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /organizations/1
  def update
    if @organization.update(organization_params)
      redirect_to @organization, notice: "Organization was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /organizations/1
  def destroy
    @organization.destroy
    redirect_to organizations_path, notice: "Organization was successfully destroyed.", status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_organization
    @organization = Organization.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def organization_params
    params.require(:organization).permit(:name, :slug)
  end
end
