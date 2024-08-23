class ApplicationController < ActionController::Base
  include SessionsHelper
  
  private
      
  def redirect_unless(url = root_url, status: :see_other, with_flash: true , flash_message: "Access denied", flash_type: :danger)
    if block_given?
      unless yield
        flash[flash_type] = flash_message if with_flash
        store_requested_url if url.match?(login_url)
        redirect_to(url, status: status) and return
      end
    end
  end
  
  def check_not_logged_in
    redirect_unless(with_flash: false) { !logged_in? }
  end
  
  def check_logged_in
    redirect_unless(login_url, flash_message: "Please, log in", flash_type: :info) { logged_in? }
  end
end
