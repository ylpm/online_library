class UsersController < ApplicationController
  include PersonableHandler

  before_action :redirect_if_logged_in, only: [:new, :create]
  
  before_action -> { redirect_unless_logged_in(root_url) }, only: [:index, :credential, :authenticate]
  
  before_action only: :credential do
    redirect_to root_url if authenticity_confirmed? || !credential_needed?
  end

  before_action only: [:show, :profile, :setting, :update, :destroy] do
    do_friendly_forwarding_unless(login_url, with_flash: {message: "Please, log in?", type: :info}) { logged_in? }
  end
  
  before_action only: [:setting, :update, :destroy] do
    do_friendly_forwarding_unless(credential_me_url) { authenticity_confirmed? }
  end
  
  before_action :check_the_requested_user_exists, only: :show  

  def index
    display_users do
      @users = User.all
    end
  end

  def new
    new_personable(User) do |new_user|
      @user = new_user
      @user.person.email_addresses.build # 2.times { @user.person.email_addresses.build }
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
  
  def credential
  end
  
  def authenticate
    respond_to do |format|
      if current_user.authenticate(params[:credential][:password])
        format.html do
          confirm_authenticity
          redirect_to(requested_url, status: :see_other) and return
          # redirect_to(setting_me_url, status: :see_other) and return
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
    # confirm_authenticity
  end

  def update
    update_personable(current_user, user_params) do |success|
      confirm_authenticity
      respond_to do |format|
        if success
          format.html do
            flash[:success] = "You have updated your settings successfully!"
            redirect_to profile_me_url, status: :see_other
            # redirect_to user_url(current_user.username), status: :see_other
          end
        else
          @user = current_user
          format.turbo_stream
          format.html {render :setting, status: :unprocessable_entity}
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
    unless @user = User.find_by_username(params[:user_username] || params[:username])
      flash[:danger] = "User not found"
      redirect_to root_url and return
    end
  end

  def check_the_requested_user_is_the_current_user
    redirect_unless(root_url) { current_user?(@user) }
  end
    
  def user_params
    params.require(:user).permit(
      :username,
      :password,
      :password_confirmation,
      person_attributes: [:first_name,
                          :middle_name,
                          :last_name,
                          :birthday,
                          :gender,
                          :id,
                          email_addresses_attributes: [:address]
                         ]
      )
  end

  def person_params = params[:user][:person]

  def display_users
    if current_user?(User.find_by_username('john')) && params[:see] == "all"
      do_friendly_forwarding_unless(credential_me_url){ authenticity_confirmed? }
      yield
    else
      flash[:danger] = "Not found"
      redirect_to root_url, status: :see_other
    end
  end
end
