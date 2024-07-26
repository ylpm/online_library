require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    # get static_pages_home_url
    get root_url  # get '/'
    assert_response 200 # :success
  end

  test "should get help" do
    # get static_pages_help_url
    get help_url # get '/help'
    assert_response :success
  end
end
