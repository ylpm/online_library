class UsersController < ApplicationController
  include PersonableHandler
  
  before_action :redirect_if_logged_in, only: [:new, :create]
    
  before_action :redirect_unless_logged_in, except: [:new, :create]
  
  before_action :check_the_requested_user_exists, except: [:index, :new, :create]
  
  before_action :check_the_requested_user_is_the_current_user, only: [:settings, :update, :destroy]
  
  def index
    display_users do
      @users = User.all
    end
  end
      
  def new
    new_personable(User) do |new_user, new_email_address|
      @user = new_user
      @email_address = new_email_address
    end
  end
  
  def show
    render :profile if current_user?(@user)
  end
    
  def create
    create_personable(User, user_params) do |new_user|
      @user = new_user
      @email_address = @user.person.email_addresses.first
      respond_to do |format|
        if @user.persisted?
          new_session_for @user
          format.html do
            flash[:success] = "Welcome!"
            redirect_to root_url, status: :see_other
          end
        else
          format.turbo_stream
          format.html {render :new, status: :unprocessable_entity}
        end
      end                               
    end
  end
  
  def settings
    @user = current_user
  end

  def update
    update_personable(current_user, user_params) do |updated_user, updated|
      respond_to do |format|
        if updated
          format.html do
            flash[:success] = "You have updated your settings successfully!"
            redirect_to user_url(current_user.username), status: :see_other
          end
        else
          @user = updated_user
          format.turbo_stream
          format.html {render :new, status: :unprocessable_entity}
        end
      end
    end
    
  end
  
  def destroy
    destroy_personable(current_user) do
      terminate_current_session
      flash[:success] = "Your account has been removed"
      redirect_to root_path, status: :see_other
    end
  end
  
  private
  
  def check_the_requested_user_exists
    redirect_unless(flash_message: "User not found") { @user = User.find_by_username(params[:user_username] || params[:username]) }
  end
  
  def check_the_requested_user_is_the_current_user
    redirect_unless(with_flash: false) { current_user?(@user) }
  end
      
  def user_params 
    params.require(:user).permit(
      :username,
      :password,
      :password_confirmation)
  end

  def person_params = params[:user][:person]
  
  def display_users
    if current_user?(User.find_by_username('john')) && params[:see] == "all"
      yield
    else
      flash[:danger] = "Not found"
      redirect_to root_url, status: :see_other
    end
  end 
end
