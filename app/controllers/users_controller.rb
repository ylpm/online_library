class UsersController < ApplicationController
  include PersonableHandler
  
  # before_action :set_user, only: [:show, :profile]
  
  before_action :check_logged_in, only: [:settings, :destroy]
  
  before_action :check_the_requested_user_exists, only: [:profile, :settings, :destroy]
  
  before_action :check_the_requested_user_is_the_current_user, only: [:settings, :destroy]
    
  def new
    @user = User.new(person: Person.new)
    @email_address = @user.person.email_addresses.new
  end
  
  def profile
  end
    
  def create    
    create_personable User, user_params do |new_user|
      @user = new_user
      @email_address = @user.person.email_addresses.first
      respond_to do |format|
        if @user.persisted?
          reset_session
          log_in @user
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
  end
  
  def destroy
  end
  
  private
  
  def set_user = @user = User.find_by_id(params[:id]) || User.find_by_username(params[:username])
    
  def user_params 
    params.require(:user).permit(
      :username, 
      :password,
      :password_confirmation) 
  end
    
  def person_params = params[:user][:person]

end
