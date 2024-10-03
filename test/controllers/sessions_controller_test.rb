require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get login page" do
    get login_path
    assert_response :success
    assert_template 'sessions/new'
  end
end

# class SessionsControllerLoginBasedActionsTest < ActionDispatch::IntegrationTest
#   def setup
#     @john = users(:john)
#     login_as(@john)
#     assert is_logged_in?
#   end
#
#   test "should redirect login when logged in" do
#     get login_path
#     assert_response :see_other
#     assert_template 'static_page/home'
#   end
# end
