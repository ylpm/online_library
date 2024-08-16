class UsersController < ApplicationController
  
  include PersonableHandler
  
  before_action :set_user, only: [:show, :update, :destroy]
  
  def show
  end
    
  def new
    @user = User.new(person: Person.new)
    @email_address = @user.person.email_addresses.new
    # @email_address = EmailAddress.new(person: @user.person)
    # @user.person.email_addresses.append(@email_address)
  end
    
  def create    
    create_personable User, user_params do |new_user|
      @user = new_user
      @email_address = @user.person.email_addresses.first
      respond_to do |format|
        if @user.persisted?
          format.html do
            flash[:success] = "Welcome!"
            redirect_to @user, status: :see_other
          end
        else
          format.turbo_stream
          format.html { render :new, status: :unprocessable_entity }
        end
      end                               
    end
  end
  
  def update
    # redirect_to @user, status: :see_other
  end
  
  def destroy
    # redirect_to root_url, status: :see_other
  end
  
  private
  
  def set_user = @user = User.find_by_id(params[:id])
    
  def user_params 
    params.require(:user).permit(
      :username, 
      :password,
      :password_confirmation) 
  end
    
  def person_params = params[:user][:person]

end
