class SessionsController < ApplicationController
  
  before_action :redirect_if_logged_in, only: [:new, :create]
  
  before_action :set_user, only: :create
  
  # before_action :redirect_unless_logged_in, only: ...
  
  before_action -> { redirect_unless_logged_in(root_url, with_flash: false) }, only: [:toggle_status, :destroy] # :logout
  
  def new
  end
  
  def create
    respond_to do |format|
      if @user&.authenticate(params[:session][:password])
        forwarding_url = requested_url
        new_session_for @user, email_address: @email_address, persistent: (params[:session][:remember_me] == '1')
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
  
  def toggle_status
    toggle_session_status
    respond_to do |format|
      format.turbo_stream
    end
  end
  
  # def logout
  def destroy
    finish_current_session
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
