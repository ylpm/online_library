class ApplicationController < ActionController::Base
  include SessionsHelper # requires a current_session method

  before_action -> { cancel_friendly_forwarding_unless {logged_in? || doing_login? || doing_credential_me? } }
  
  private

  def cancel_friendly_forwarding_unless
    if block_given?
      reset_requested_url unless yield
    else
      reset_requested_url
    end
  end
  
  # def redirect_unless_authenticity_confirmed
  #   redirect_unless(credential_me_url, with_flash: false) { authenticity_confirmed? }
  # end
end
