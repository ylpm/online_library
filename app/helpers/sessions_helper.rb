module SessionsHelper
  
  include RedirectableHandler
  
  def log_in(user, with_email_address: nil, remember: false)
    reset_session
    new_session_for(@user, email_address_identifier: with_email_address, persistent: remember)
    confirm_authenticity
  end
  
  def current_session
    return @current_session if @current_session
    
    if session_id = session[:_sid]
      @current_session = Session.find_by_id(session_id)
      update_remembering_status
    elsif old_session_id = cookies.encrypted[:_ri]
      old_remember_token = cookies[:_rt]
      delete_tracking_cookies
      if old_session = Session.find_by_id(old_session_id)
        if old_session.remembered_with?(old_remember_token)
          new_session_for(old_session.user, email_address_identifier: old_session.email_address_identifier, persistent: true)        
        end
        old_session.destroy
      end
    else
      delete_tracking_cookies
    end
    if @current_session && @current_session.remember_token.blank?
      @current_session.rescue_remember_token(cookies[:_rt])
    end
    @current_session
  end
  
  def current_session?(session)
    raise ArgumentError, "Argument must be an instance of Session" unless session.instance_of? Session
    session == current_session
  end
  
  def logged_in?
    !current_session.nil?
  end
  
  def toggle_session_status
    raise "No current session" unless logged_in?
    if current_session.remembered?
      current_session.forget
      delete_remember_cookies
      return
    end
    current_session.remember
    set_remember_cookies
  end
  
  def log_out
    raise "No current session" unless logged_in?
    current_session.destroy if current_session.persisted?
    @current_user = @current_session = nil
    reset_session
    delete_tracking_cookies
    yield if block_given?
  end
    
  def current_user
    raise "No current user" unless logged_in?
    @current_user || current_session.user
  end
  
  def current_user?(user)
    raise ArgumentError, "Argument must be an instance of User" unless user.instance_of? User
    user == current_user
  end
  
  def confirm_authenticity
    cookies.delete(:_auth)
    cookies.encrypted[:_auth] = { value: current_session.id,
                                  expires: 7.minutes.from_now.utc, 
                                  httponly: true }
  end

  def authenticity_confirmed?
    if cookies.encrypted[:_auth] == current_session.id
      true
    else
      cookies.delete(:_auth)
      false
    end
  end
  
  def redirect_if_logged_in
    redirect_unless(root_url) { !logged_in? }
  end

  def redirect_unless_logged_in(url, with_flash: {message: nil, type: nil})
    redirect_unless(url, with_flash: {message: with_flash[:message], 
                                         type: with_flash[:type]}) { logged_in? }
  end
  
  def do_friendly_forwarding_unless(url, with_flash: {message: nil, type: nil})
    if block_given?
      unless yield
        # store_requested_url
        session[:_ffurl] = request.original_url if request.get?
        redirect_unless(url, with_flash: {message: with_flash[:message], 
                                             type: with_flash[:type]}) { false }
      end
    end
  end
  
  def friendly_forwarding_url
    session[:_ffurl]
  end
  
  def cancel_friendly_forwarding
    session.delete(:_ffurl)
  end
  
  def credential_needed?
    !friendly_forwarding_url.nil?
  end
  
  # def store_requested_url
  #   session[:_rurl] = request.original_url if request.get?
  # end

  # def requested_url
  #   session[:_rurl]
  # end
  #
  # def reset_requested_url
  #   session.delete(:_rurl)
  # end
  
  # def doing_login?
  #   request.original_url.match?(login_url)
  #   # params[:controller].match?('sessions') && params[:action].match?(/new|create/)
  # end
  #
  # def doing_credential_me?
  #   request.original_url.match?(credential_me_url)
  # end
  
  
  private
  
  def new_session_for(user, email_address_identifier: nil, persistent: false)
    raise ArgumentError, "Invalid user" unless user.instance_of? User
    raise ArgumentError, "Invalid email address" unless email_address_identifier.nil? || email_address_identifier.instance_of?(EmailAddress)
    @current_user = user
    @current_session = @current_user.sessions.create!(email_address_identifier: email_address_identifier)
    @current_session.remember if persistent
    start_session_tracking # set necessary cookies
  end

  def start_session_tracking
    session[:_sid] = current_session.id
    set_remember_cookies if current_session.remembered?
  end
  
  def set_remember_cookies
    cookies.encrypted[:_ri] = { value: current_session.id, 
                                 expires: 6.months.from_now.utc,
                                 httponly: true }
    cookies[:_rt] = { value: current_session.remember_token, 
                      expires: 6.months.from_now.utc,
                      httponly: true }
  end
  
  def update_remembering_status
    if cookies[:_ri].nil? || cookies[:_rt].nil?
      current_session.forget
      delete_remember_cookies
    end
  end
  
  def delete_remember_cookies
    cookies.delete(:_ri)
    cookies.delete(:_rt)
  end
  
  def delete_tracking_cookies
    delete_remember_cookies
    cookies.delete(:_auth)
  end
end
