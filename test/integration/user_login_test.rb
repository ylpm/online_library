require "test_helper"

class UserLoginTest < ActionDispatch::IntegrationTest
  def setup
  end
  
  test "login with invalid information" do
    get login_path
    assert_template "sessions/new"
    post login_path, params: {session: {login: "", password: ""}}
    # assert_response :unprocessable_entity # for format.html
    assert_select "div.alert-danger", "Ooops! no match"
    assert flash.empty?
  end
end
