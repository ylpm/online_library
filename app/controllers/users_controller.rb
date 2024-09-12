class UsersController < ApplicationController
  include PersonableHandler

  before_action :redirect_if_logged_in, only: [:new, :create]
  
  before_action :redirect_unless_logged_in, except: [:index, :new, :create, :credentials, :authenticate]
  
  before_action -> { redirect_unless_logged_in(root_url, with_flash: false) }, only: [:index, :credentials, :authenticate]
  
  before_action only: :credentials do
    redirect_unless(root_url, with_flash: false) { !authenticity_confirmed? }
  end

  before_action :check_the_requested_user_exists, except: [:index, :new, :create, :credentials, :authenticate]

  before_action :check_the_requested_user_is_the_current_user, only: [:settings, :update, :destroy]
  
  before_action :check_authenticity, only: [:settings, :update, :destroy]

  def index
    display_users do
      @users = User.all
    end
  end

  def new
    new_personable(User) do |new_user|
      @user = new_user
      @user.person.email_addresses.build # 2.times { @user.person.email_addresses.build }
      render :user_form
    end
  end

  def show
    render :profile if current_user?(@user)
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
          format.html {render :user_form, status: :unprocessable_entity}
        end
      end                               
    end
  end
  
  def credentials
  end
  
  def authenticate
    respond_to do |format|
      if current_user.authenticate(params[:credentials][:password])
        format.html do
          confirm_authenticity
          redirect_to(settings_user_url(current_user.username), status: :see_other) and return
        end
      else
        # @credentials_error_message = 'Wrong password'
        # format.turbo_stream
        flash.now[:danger] = 'Wrong password'
        format.html {render :credentials, status: :unprocessable_entity}
      end
    end
  end

  def settings
    @user = current_user
    confirm_authenticity
    render :user_form
  end

  def update
    update_personable(current_user, user_params) do |success|
      confirm_authenticity
      respond_to do |format|
        if success
          format.html do
            flash[:success] = "You have updated your settings successfully!"
            redirect_to user_url(current_user.username), status: :see_other
          end
        else
          @user = current_user
          format.turbo_stream
          format.html {render :user_form, status: :unprocessable_entity}
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
      :password_confirmation,
      person_attributes: [:first_name,
                          :middle_name,
                          :last_name,
                          :birthday,
                          :id,
                          email_addresses_attributes: [:address]
                         ]
      )
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
