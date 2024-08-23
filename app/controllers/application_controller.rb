class ApplicationController < ActionController::Base
  include SessionsHelper
  
  private
      
  def redirect_to_unless(url = root_url, status: :see_other, with_flash: true , flash_message: "Access denied", flash_type: :danger)
    if block_given?
      unless yield
        flash[flash_type] = flash_message if with_flash
        store_requested_url if url.match?(login_url)
        redirect_to(url, status: status) and return
      end
    end
  end
  
  def check_logged_in
    redirect_to_unless(login_url, flash_message: "Please, log in", flash_type: :info) { logged_in? }
  end
  
  def check_the_requested_user_exists
    redirect_to_unless(flash_message: "User not found") { @user = User.find_by_id(params[:user_id] || params[:id]) || User.find_by_username(params[:username]) }
  end
  
  def check_the_requested_user_is_the_current_user
    redirect_to_unless { current_user?(@user) }
  end
end
