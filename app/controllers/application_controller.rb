class ApplicationController < ActionController::Base
  include SessionsHelper # requires a current_session method

  before_action -> { cancel_friendly_forwarding_unless {logged_in? || doing_login?} }
  
  private

  def cancel_friendly_forwarding_unless
    if block_given?
      reset_requested_url unless yield
    else
      reset_requested_url
    end
  end
  
  def check_authenticity
    redirect_unless(credentials_url, with_flash: false) { authenticity_confirmed? }
  end
end
