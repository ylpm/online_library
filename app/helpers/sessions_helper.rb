module SessionsHelper
  
  include RedirectableHandler
  
  def new_session_for(user, email_address: nil, persistent: false)
    raise ArgumentError, "Invalid user" unless user.instance_of? User
    raise ArgumentError, "Invalid email address" unless email_address.nil? || email_address.instance_of?(EmailAddress)
    @current_user = user
    @current_session = @current_user.sessions.create!(email_address: email_address)
    @current_session.remember if persistent
    start_session_tracking # set necessary cookies
    confirm_authenticity
  end
  
  def current_session
    return @current_session if @current_session
    
    if session_id = session[:_sid]
      @current_session = Session.find_by_id(session_id)
    elsif old_session_id = cookies.encrypted[:_sid]
      old_remember_token = cookies[:_rt]
      reset_session_tracking
      old_session = Session.find_by_id(old_session_id)
      if old_session
        if old_session.remembered_with?(old_remember_token)
          new_session_for(old_session.user, email_address: old_session.email_address, persistent: true)        
        end
        old_session.destroy
      end
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
    # current_session.remembered? ? forget_current_session : remember_current_session
  end
  
  def terminate_current_session
    raise "No current session" unless logged_in?
    current_session.destroy if current_session.persisted?
    @current_user = @current_session = nil
    reset_session_tracking
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
    cookies[:_auth] = { value:   true,
                        expires: 5.minutes.from_now }
  end

  def authenticity_confirmed?
    cookies[:_auth]
  end

  # ******************************************
  # Pasar esto para otro modulo mas apropiado:
  # ******************************************
  
  def redirect_if_logged_in
    redirect_unless(root_url) { !logged_in? }
  end

  def redirect_unless_logged_in(url, with_flash: {message: nil, type: nil})
    redirect_unless(url, with_flash: {message: with_flash[:message], type: with_flash[:type]}) { logged_in? }
  end
  
  def do_friendly_forwarding_unless(url, with_flash: {message: nil, type: nil})
    if block_given?
      unless yield
        store_requested_url
        redirect_unless(url, with_flash: {message: with_flash[:message], type: with_flash[:type]}) { false }
      end
    end
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
  
  def friendly_forwarding_abandoned?
    (!doing_login? && !doing_credential_me?)
  end
  
  def doing_login?
    request.original_url.match?(login_url)
    # params[:controller].match?('sessions') && params[:action].match?(/new|create/)
  end
  
  def doing_credential_me?
    request.original_url.match?(credential_me_url)
  end
  
  def credential_needed?
    !requested_url.nil?
  end
  
  # ******************************************
  
  private

  def start_session_tracking
    reset_session
    session[:_sid] = @current_session.id # current_session.id
    set_remember_cookies if current_session.remembered?
  end
  
  def set_remember_cookies
    # SET PERMANENT COOKIES.                                   # cookies.permanent method is equivalent to:
    cookies.permanent.encrypted[:_sid] = @current_session.id   # cookies.encrypted[:_sid] = {value: current_session.id, 
                                                               #                           expires: 6.months.from_now.utc}
    cookies.permanent[:_rt] = @current_session.remember_token  # cookies[:_rt] = {value: current_session.remember_token, 
                                                               #                expires: 6.months.from_now.utc}
  end
  
  def reset_session_tracking
    reset_session
    delete_remember_cookies
    cookies.delete(:_auth)
  end
  
  def delete_remember_cookies
    cookies.delete(:_sid)
    cookies.delete(:_rt)
  end
  
  # def remember_current_session
  #   current_session.remember
  #   set_remember_cookies
  # end
  
  # def forget_current_session
  #   current_session.forget
  #   delete_remember_cookies
  # end
  
end
