class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action -> { cancel_friendly_forwarding_unless {logged_in? || doing_login?} }

  private

  def cancel_friendly_forwarding_unless
    if block_given?
      reset_requested_url unless yield
    else
      reset_requested_url
    end
  end
end
