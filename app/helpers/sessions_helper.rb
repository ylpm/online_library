module SessionsHelper
  include RedirectableHandler
  
  def log_in(arg)
    if arg.instance_of?(User)
      @current_session = arg.sessions.create
    elsif arg.instance_of?(EmailAddress)
      @current_session = arg.owner.user.sessions.create(email_address: arg)
    else
      raise ArgumentError
    end
    session[:_sid] = @current_session.id
    @current_session
  end
  
  def current_session
    return @current_session if @current_session
    if session_id = session[:_sid]
      @current_session = Session.find_by_id(session_id)
    end
  end
  
  def current_session?(session)
    session&. == current_session
  end
  
  def current_user
    @current_user ||= current_session.user
  end
  
  def current_user?(user)
    user&. == current_user
  end
  
  def logged_in?
    !current_session.nil?
  end
  
  def log_out
    if logged_in?
      reset_session
      @current_user = @current_session = nil
    end
  end
  
  def redirect_if_logged_in
    redirect_unless(with_flash: false) { !logged_in? }
  end

  def redirect_unless_logged_in(url = login_url, with_flash: true, flash_message: "Please, log in", flash_type: :info)
    redirect_unless(url, with_flash: with_flash, flash_message: flash_message, flash_type: flash_type) { logged_in? }
  end
  
  def store_requested_url
    session[:_rurl] = request.original_url if request.get?
  end

  def requested_url
    session[:_rurl]
  end
  
  def reset_requested_url
    session.delete(:_rurl)
  end
  
  def doing_login?
    request.original_url.match?(login_url)
    # params[:controller].match?('sessions') && params[:action].match?(/new|create/)
  end
end
