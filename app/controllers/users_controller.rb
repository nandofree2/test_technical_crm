class UsersController < ApplicationController
  before_action :authorize_admin!, only: %i[index new create]

  def index
    @users = current_organization.users
    render json: @users
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    User.transaction do
      @user.save!
      @user.memberships.create!(organization: current_organization, role: :sales, member_status: :active)
    end

    if @user.persisted?
      redirect_to @user
    else
      render :new
    end
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  def show
    @user = current_user
    @memberships = @user.memberships.includes(:organization)
  end

  def switch_organization
    switch_service = MembershipOperation::SwitchService.new(current_user, params[:membership_id])

    if switch_service.switch
      redirect_to user_path(current_user), notice: "Successfully switched organization"
    else
      render json: { error: switch_service.error_message }, status: :forbidden
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to user_path(current_user)
    else
      render :edit
    end
  end

  private

  def authorize_admin!
    return if current_user_membership&.admin?

    raise CanCan::AccessDenied
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
