require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @base_title = 'Sample App'
  end
  test "should get root/home page" do
    # get static_pages_home_url
    get root_url  # get '/'
    assert_response 200 # :success
    assert_select 'title', "Home | #{@base_title}"
    assert_select 'h1', 'Sample App'
  end

  test "should get help page" do
    # get static_pages_help_url
    get help_url # get '/help'
    assert_response :success
    assert_select 'title', "Help | #{@base_title}"
    assert_select 'h1', 'Help'
  end
  
  test "should get about page" do
    get about_url
    assert_response :success
    assert_select 'title', "About | #{@base_title}"
    assert_select 'h1', 'About'
  end
end
