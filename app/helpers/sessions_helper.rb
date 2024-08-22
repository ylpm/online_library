module SessionsHelper
  def log_in(user)
    user_session = user.sessions.create
    session[:_sid] = user_session.id
    user_session
  end
  
  def current_session
    return @current_session if @current_session
    if session_id = session[:_sid]
      user_session = Session.find_by_id(session_id)
      @current_session = user_session
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
end
