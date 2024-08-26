class SessionsController < ApplicationController
  
  before_action :check_not_logged_in, only: [:new, :create]
  
  before_action :set_user, only: :create
  
  before_action :check_logged_in, only: [:destroy]
  
  def new
  end
  
  def create
    respond_to do |format|
      if @user&.authenticate(params[:session][:password]) 
        forwarding_url = requested_url
        reset_session
        log_in(@email_address || @user)
        format.html do
          flash[:success] = "You have logged in successfully!"
          redirect_to(forwarding_url || root_path, status: :see_other) and return
        end
      else
        @login_error = "ooops! no match"
        format.turbo_stream
        format.html {render :new, status: :unprocessable_entity}
      end
    end
  end
  
  def destroy
    log_out
    flash[:success] = "You have logged out successfully!"
    redirect_to root_url, status: :see_other
  end
  
  private
  
  def set_user
    # @user = User.find_by_login(params[:session][:login])
    login_identifier = params[:session][:login]
    
    unless @user = User.find_by_username(login_identifier)
      @email_address = EmailAddress.find_by_address(login_identifier)
      @user = @email_address.owner.user if @email_address&.activated?
    end 
  end
end
