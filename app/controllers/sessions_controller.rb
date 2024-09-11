class SessionsController < ApplicationController
  
  before_action :redirect_if_logged_in, only: [:new, :create]
  
  before_action only: :create do
    set_user
    remember_me?
  end
  
  # before_action :redirect_unless_logged_in, only: ...
  
  before_action -> { redirect_unless_logged_in(root_url, with_flash: false) }, only: [:toggle_status, :destroy]
  
  def new
  end
  
  def create
    respond_to do |format|
      if @user&.authenticate(params[:login][:password])
        forwarding_url = requested_url
        new_session_for @user, email_address: @email_address, persistent: @remember_me
        format.html do
          flash[:success] = "You have logged in successfully!"
          redirect_to(forwarding_url || root_path, status: :see_other) and return
        end
      else
        @login_error_message = "ooops! no match"
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
  
  def destroy
    terminate_current_session do
      flash[:success] = "You have logged out successfully!"
      redirect_to root_url, status: :see_other
    end
  end
  
  private
  
  def set_user
    # @user = User.find_by_login(params[:session][:login])
    @login_identifier = params[:login][:identifier]
    
    unless @user = User.find_by_username(@login_identifier)
      @email_address = EmailAddress.find_by_address(@login_identifier)
      @user = @email_address.owner.user if @email_address&.activated?
    end    
  end
  
  def remember_me? = (@remember_me = (params[:login][:remember_me] == '1'))
end
