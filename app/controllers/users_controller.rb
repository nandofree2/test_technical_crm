class UsersController < ApplicationController
  def index
    @users = User.all
    render json: @users
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user
    else
      render :new
    end
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
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to @user
    else
      render :edit
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
