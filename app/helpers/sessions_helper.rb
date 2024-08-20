module SessionsHelper
  def login
    @logged_in = true
  end
  
  def logged_in? = @logged_in
end
