class UsersController < ApplicationController
  include PersonableHandler
  
  before_action :cancel_friendly_forwarding, except: [:credential, :authenticate]

  before_action :redirect_if_logged_in, only: [:new, :create]
  
  before_action -> { redirect_unless_logged_in(root_url) }, only: [:credential, :authenticate]
  
  before_action only: [:credential, :authenticate] do
    redirect_to root_url if authenticity_confirmed? || !credential_needed?
  end

  before_action only: [:show, :profile, :setting, :update, :destroy] do
    do_friendly_forwarding_unless(login_url, with_flash: {message: "Please, log in", type: :info}) { logged_in? }
  end

  before_action only: [:setting, :update, :destroy] do
    do_friendly_forwarding_unless(credential_me_url) { authenticity_confirmed? }
  end
  
  before_action :check_the_requested_user_exists, only: :show

  def new
    new_personable(User) do |new_user|
      @user = new_user
      @user.person.email_addresses.build # 2.times { @user.person.email_addresses.build } # crear el usuario con 2 direcciones de email
    end
  end

  def show
    render :profile if current_user?(@user)
  end

  def profile
  end

  def create
    create_personable(User, user_params) do |new_user|
      @user = new_user
      respond_to do |format|
        if @user.persisted?
          log_in @user
          format.html do
            flash[:success] = "Welcome!"
            redirect_to root_url, status: :see_other
          end
        else
          # @user.person.email_addresses.build if @user.person.email_addresses.length == 1 # crear el usuario con 2 direcciones de email
          format.turbo_stream
          format.html {render :new, status: :unprocessable_entity}
        end
      end
    end
  end

  def credential
  end

  def authenticate
    respond_to do |format|
      if current_user.authenticate(params[:credential][:password])
        format.html do
          confirm_authenticity
          redirect_to(friendly_forwarding_url || root_url, status: :see_other) and return
        end
      else
        # @credentials_error_message = 'Wrong password'
        # format.turbo_stream
        flash.now[:danger] = 'Wrong password'
        format.html {render :credential, status: :unprocessable_entity}
      end
    end
  end

  def setting
    @user = current_user
    @user.person.email_addresses.build # para adicionar otra direccion de email
  end

  def update 
    update_personable(current_user, user_params) do |success|
      confirm_authenticity
      respond_to do |format|
        if success
          format.html do
            flash[:success] = "You have updated your settings successfully!"
            redirect_to setting_me_url, status: :see_other
          end
        else
          @user = current_user
          @user.person.email_addresses.build if @user.person.email_addresses.select{|e| !e.persisted?}.empty?
          format.turbo_stream
          format.html {render :setting, status: :unprocessable_entity}
        end
      end
    end
  end

  def destroy
    destroy_personable(current_user) do
      log_out do
        flash[:success] = "Your account has been removed"
        redirect_to root_path, status: :see_other
      end
    end
  end

  private

  def check_the_requested_user_exists
    unless @user = User.find_by_username(params[:user_username] || params[:username])
      flash[:danger] = "User not found"
      redirect_to root_url and return
    end
  end

  def check_the_requested_user_is_the_current_user
    redirect_unless(root_url) { current_user?(@user) }
  end
    
  def user_params
    if params[:user][:person_attributes].has_key?(:email_addresses_attributes)
      params[:user][:person_attributes][:email_addresses_attributes].delete_if { |id, email| email[:address].blank? }
    end
    
    params.require(:user).permit(
      :username,
      :password,
      :password_confirmation,
      person_attributes: [:first_name,
                          :middle_name,
                          :last_name,
                          :birthday,
                          :gender,
                          :primary_email_address_id,
                          :id,
                          email_addresses_attributes: [:address]
                         ]
      )
  end
end
