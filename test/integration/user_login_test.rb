require "test_helper"

class UserLoginTest < ActionDispatch::IntegrationTest
end

class InvalidLoginTest < UserLoginTest
  
  test "login with invalid information" do
    get login_path
    assert_template "sessions/new"
    post login_path, params: {session: {login: "", password: ""}}
    # assert_response :unprocessable_entity # for format.html
    assert_select "div.alert-danger", "Ooops! no match"
    assert flash.empty?
  end
end

class ValidLoginTest < UserLoginTest
  def setup
    @test_user = users(:john)
    @test_password = "Abcde123*"
  end
  
  test "login with username, followed by logout, and simulating a second logout from another window" do
    # STEP 1. Visit login page
    get login_path
    assert_template "sessions/new"
    
    # STEP 2. Log in with username
    assert_difference 'Session.count', 1 do
      post login_path, params: {session: {login: @test_user.username, 
                                       password: @test_password}}  
    end   
    # assert is_logged_in?
    assert_redirected_to root_url
    
    # STEP 3. Check the links changed after logging in
    follow_redirect!
    assert_template "static_pages/home"
    assert_not flash.empty?
    assert_select "div.alert-success", "You have logged in successfully!"
    assert_select "h1", text: "Welcome! #{@test_user.person.first_name}", count: 1
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", signup_path, count: 0
    assert_select "ul.dropdown-menu", count: 1
    assert_select "div.login-identifier", text: @test_user.username, count: 1
    assert_select "a[href=?]", user_path(@test_user.username), count: 1, text: "View your profile"
    assert_select "a[href=?]", settings_user_path(@test_user.username), count: 1, text: "Settings"
    assert_select "a[href=?]", logout_path, count: 1, text: "Logout"
    
    # STEP 4. Log out
    delete logout_path # get logout_path
    assert_response :see_other
    # assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_template "static_pages/home"
    assert_not flash.empty?
    assert_select "div.alert-success", "You have logged out successfully!"
    # check the links changed again
    assert_select "h1", text: "Welcome! #{@test_user.person.first_name}", count: 0
    assert_select "ul.dropdown-menu", count: 0
    assert_select "a[href=?]", login_path, count: 1
    assert_select "a[href=?]", signup_path, count: 1
    
    # STEP 5. Simulating a second log out from another window of the navigator
    delete logout_path  # aqui en el entorno de pruebas 
                        # si me funciona correctamente el redirect para el segundo logout con delete, 
                        # pero no en el entorno de desarrollo ni production con el navegador real.
                        # use get logout_path pero en desarrollo y produccion get no es apropiado
    assert_response :see_other
    assert_redirected_to root_url
    follow_redirect!
    assert_template "static_pages/home"
    assert flash.empty? # testing the custom call of redirect_unless_logged_in before destroy action
  end
  
  test "login with email address, followed by logout, and simulating a second logout from another window" do
    # STEP 1. Visit login page
    get login_path
    assert_template "sessions/new"
    
    # STEP 2. Log in with an active email address
    test_email_address = email_addresses(:john_at_hey)
    test_email_address.activated = true # activar directamente en los fixtures
    test_email_address.save
    assert_difference 'Session.count', 1 do
      post login_path, params: {session: {login: test_email_address.address, 
                                       password: @test_password}} 
    end
    # assert is_logged_in?
    assert_redirected_to root_url
    
    # STEP 3. Check the links changed after logging in
    follow_redirect!
    assert_template "static_pages/home"
    assert_not flash.empty?
    assert_select "div.alert-success", "You have logged in successfully!"
    assert_select "h1", text: "Welcome! #{@test_user.person.first_name}", count: 1
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", signup_path, count: 0
    assert_select "ul.dropdown-menu", count: 1
    assert_select "div.login-identifier", text: test_email_address.address, count: 1
    assert_select "a[href=?]", user_path(@test_user.username), count: 1, text: "View your profile"
    assert_select "a[href=?]", settings_user_path(@test_user.username), count: 1, text: "Settings"
    assert_select "a[href=?]", logout_path, count: 1, text: "Logout"
    
    # STEP 4. Log out
    delete logout_path # get logout_path
    assert_response :see_other
    # assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_template "static_pages/home"
    assert_not flash.empty?
    assert_select "div.alert-success", "You have logged out successfully!"
    # check the links changed again
    assert_select "h1", text: "Welcome! #{@test_user.person.first_name}", count: 0
    assert_select "ul.dropdown-menu", count: 0
    assert_select "a[href=?]", login_path, count: 1
    assert_select "a[href=?]", signup_path, count: 1
    
    # STEP 5. Simulating a second log out from another window of the navigator
    delete logout_path  # aqui en el entorno de pruebas 
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
