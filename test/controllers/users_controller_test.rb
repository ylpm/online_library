require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @test_user = users(:john)
  end
end

class UsersControllerUnloggedAccessTest < UsersControllerTest

  test "should redirect from profile action when not logged in" do
    get profile_me_path
    check_redirection_to_login_page
  end

  test "should redirect from show action when not logged in" do
    get user_path(@test_user.username)
    check_redirection_to_login_page
  end
  
  test "should redirect from setting action when not logged in" do
    get setting_me_path
    check_redirection_to_login_page
  end
  
  test "should redirect from credential action when not logged in" do
    get credential_me_path
    assert_response :see_other
    assert_redirected_to root_url
  end
  
  test "should redirect from authenticate action when not logged in" do
    post credential_me_path
    assert_response :see_other
    assert_redirected_to root_url
  end
  
  test "should redirect from destroy action when not logged in" do
    delete remove_me_path
    check_redirection_to_login_page
  end
  
  private
  
  def check_redirection_to_login_page
    assert_response :see_other
    assert_redirected_to login_url
    assert_not flash.empty?
  end
end

class UsersControllerLoggedinAccessTest < UsersControllerTest
  def setup
    super
    # log_in_as(@test_user)
  end
 
end
