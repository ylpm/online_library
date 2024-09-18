require "test_helper"

class UserLoginTest < ActionDispatch::IntegrationTest
  def setup
    @test_user = users(:john)
  end
  
  test "login path" do
    get login_path
    assert_template "sessions/new"
  end
end

class InvalidLoginTest < UserLoginTest
  
  test "login with invalid information" do
    assert_no_difference "Session.count" do
      post login_path, params: {login: {identifier: "invalid_username", 
                                          password: ""}}, 
                          xhr: true # xhr indica que la respuesta es con turbo stream
    end
    check_status_after_failed_login
  end
  
  test "login with invalid password" do
    assert_no_difference "Session.count" do
      post login_path, params: {login: {identifier: @test_user.username, 
                                          password: "invalid"}},
                          xhr: true
    end
    check_status_after_failed_login
  end
  
  private
  
  def check_status_after_failed_login
    assert_not is_logged_in?
    assert_select "div.alert-danger", "Ooops! no match"
    assert flash.empty?
  end
end

class ValidLoginTest < UserLoginTest
  def setup
    super
    @test_password = "Abcde123*"
    @test_email_address = @test_user.email_addresses.first
  end
  
  test "login with username, followed by logout, and simulating a second logout from another window" do
    check_valid_login_with :username
  end

  test "login with email address, followed by logout, and simulating a second logout from another window" do
    check_valid_login_with :email_address
  end

  private

  def check_valid_login_with(identifier_type)
    do_login_with(identifier_type)
    check_status_after_valid_login
    check_status_after_logging_out
    simulate_a_second_logout_from_another_window
  end  

  def do_login_with(identifier_type)
    # STEP 1. Visit the login page
    get login_path
    assert_template "sessions/new"

    # Step 2. Set the login identifier
    if identifier_type == :username
      identifier = @test_user.username
    elsif identifier_type == :email_address
      identifier = @test_email_address.address
    else
      raise ArgumentError, "Use :username or :email_address symbols as argument"
    end

    # STEP 3. Log in
    assert_difference 'Session.count', 1 do
      post login_path, params: {login: {identifier: identifier,
                                          password: @test_password}}
    end
  end

  def check_status_after_valid_login
    assert is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_template "static_pages/home"
    assert_not flash.empty?
    assert_select "div.alert-success", "You have logged in successfully!"
    assert_select "h1", text: "Welcome! #{@test_user.first_name}", count: 1
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", signup_path, count: 0
    assert_select "ul.dropdown-menu", count: 1
    assert_select "div.login-identifier", text: @test_user.sessions.last.login_identifier, count: 1
    assert_select "a[href=?]", profile_me_path, count: 1, text: "View your profile"
    assert_select "a[href=?]", setting_me_path, count: 1, text: "Settings"
    assert_select "a[href=?]", logout_me_path, count: 1, text: "Log out"   
  end

  def check_status_after_logging_out
    # -> Do log out
    delete logout_me_path # get logout_path
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
    # -> Visit the view
    follow_redirect!
    assert_template "static_pages/home"
    assert_not flash.empty?
    assert_select "div.alert-success", "You have logged out successfully!"
    # -> Check the links changed again
    assert_select "h1", text: "Welcome! #{@test_user.first_name}", count: 0
    assert_select "ul.dropdown-menu", count: 0
    assert_select "a[href=?]", login_path, count: 1
    assert_select "a[href=?]", signup_path, count: 1
  end

  def simulate_a_second_logout_from_another_window
    assert_not is_logged_in?
    delete logout_me_path  # aqui en el entorno de pruebas 
                           # si me funciona correctamente el redirect para el segundo logout con delete, 
                           # pero no en el entorno de desarrollo ni production con el navegador real.
                           # use get logout_path pero en desarrollo y produccion get no es apropiado
    assert_response :see_other
    assert_redirected_to root_url
    follow_redirect!
    assert_template "static_pages/home"
    assert flash.empty? # testing the custom call of redirect_unless_logged_in before destroy action
  end
end

class RememberMeTest < UserLoginTest

  test "login with remembering" do
    assert_difference 'Session.count', 1 do
      login_as(@test_user, password: 'Abcde123*', remember_me: true)
    end
    assert is_logged_in?
    assert assigns(:current_session).remembered?
    assert_not cookies[:_rt].blank?
    assert_equal cookies[:_rt], assigns(:current_session).remember_token
    assert_difference 'Session.count', -1 do
      delete logout_me_path
    end
    assert_not is_logged_in?
    assert assigns(:current_session).nil?
    assert cookies[:_rt].blank?
  end

  test "login without remembering" do
    assert_difference 'Session.count', 1 do
      login_as(@test_user, password: 'Abcde123*', remember_me: false)
    end
    assert is_logged_in?
    assert_not assigns(:current_session).remembered?
    assert cookies[:_rt].blank?
    assert assigns(:current_session).remember_token.nil?
    assert_difference 'Session.count', -1 do
      delete logout_me_path
    end
    assert_not is_logged_in?
    assert assigns(:current_session).nil?
  end
  
  test "toggling user-menu remeber-me option" do
    # login with remembering:
    login_as(@test_user, password: 'Abcde123*', remember_me: true)
    assert is_logged_in?
    assert_redirected_to root_url
    # verify that the remember-me checkbox in the user menu is CHECKED:
    follow_redirect!
    assert_template 'static_pages/home'
    assert_select 'a[href=?]', forget_me_path
    assert_select 'input#remember-me[type="checkbox"][checked]', true
    # toggle the status of the remember-me checkbox in the user menu:
    patch forget_me_path, xhr: true # xhr indica que la respuesta es con turbo stream
    # verify that the remember-me checkbox in the user menu is NOT CHECKED:
    assert_select 'a[href=?]', remember_me_path
    assert_select 'input#remember-me[type="checkbox"][checked]', false
    delete logout_me_path
  end
end

class UserDestroyAfterLogin < ValidLoginTest
  
  # probando la sobreescritura del metodo destroy en la clase User
  
  test "should destroy the user after login with username" do
    do_login_with :username
    check_status_after_valid_login
    remove_user_and_check_status
  end
  
  test "should destroy the user after login with email address" do
    do_login_with :email_address
    check_status_after_valid_login
    remove_user_and_check_status 
  end
  
  private
  
  def remove_user_and_check_status
    assert_difference 'User.count', -1 do
      delete remove_me_path
    end
    assert_response :see_other
    assert_redirected_to root_url
    assert_not is_logged_in?
  end
end
