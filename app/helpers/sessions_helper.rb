module SessionsHelper
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
  
  def store_requested_url
    session[:_rurl] = request.original_url if request.get?
  end

  def requested_url
    session[:_rurl]
  end
end
