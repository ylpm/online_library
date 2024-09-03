module SessionsHelper
  
  include RedirectableHandler
  
  def start_session_for(user, email_address: nil, persistent: false)
    raise ArgumentError, "Invalid user" unless user.instance_of? User
    raise ArgumentError, "Invalid email address" unless email_address.nil? || email_address.instance_of?(EmailAddress)
    @current_user = user
    @current_session = @current_user.sessions.create(email_address: email_address)
    @current_session.remember if persistent
    start_session_tracking # set necessary cookies
  end
  
  def finish_current_session
    raise "No current session" if !logged_in?
    stop_session_tracking # unset cookies
    current_session.destroy
    @current_user = @current_session = nil
  end
  
  def current_session
    return @current_session if @current_session
    if session_id = session[:_sid]
      @current_session = Session.find_by_id(session_id)
    elsif old_session_id = cookies.encrypted[:_sid]
      old_session = Session.find_by_id(old_session_id)
      if old_session&.remembered_with?(cookies[:_rt])
        start_session_for(old_session.user, email_address: old_session.email_address, persistent: true)
        old_session.destroy
      end
    end
  end
  
  def logged_in?
    !current_session.nil?
  end
  
  def current_session?(session)
    raise ArgumentError, "Argument must be an instance of Session" unless session.instance_of? Session
    session == current_session
  end
  
  def current_user
    @current_user || current_session.user if logged_in?
  end
  
  def current_user?(user)
    raise ArgumentError, "Argument must be an instance of User" unless user.instance_of? User
    user == current_user
  end


  # ******************************************
  # Pasar esto para otro modulo mas apropiado:
  # ******************************************
  
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
  
  # ******************************************
  
  
  private

  def start_session_tracking
    raise "No current session" unless current_session
    reset_session
    session[:_sid] = current_session.id
    
    if current_session.remembered?
      # set permanent cookies.                                 # cookies.permanent method is equivalent to:
      cookies.permanent.encrypted[:_sid] = current_session.id  # cookies.encrypted[:_sid] = {value: current_session.id, 
                                                               #                           expires: 20.years.from_now.utc}
      cookies.permanent[:_rt] = current_session.remember_token # cookies[:_rt] = {value: current_session.remember_token, 
                                                               #                expires: 20.years.from_now.utc}
    end
  end
  
  def stop_session_tracking
    reset_session
    if current_session.remembered?
      cookies.delete(:_sid)
      cookies.delete(:_rt)
    end
  end
end
