require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @base_title = 'Online Library'
  end
  
  test "should get root/home page" do
    # get static_pages_home_url
    get root_url  # get '/'
    assert_response 200 # :success
    assert_select 'title', title_for_page(:home)
  end

  test "should get help page" do
    # get static_pages_help_url
    get help_url # get '/help'
    assert_response :success
    assert_select 'title', title_for_page(:help)
    assert_select 'h1', 'Help'
  end
  
  test "should get about page" do
    get about_url
    assert_response :success
    assert_select 'title', title_for_page(:about)
    assert_select 'h1', 'About'
  end
  
  private
  
  # pasar este endless method para el test_helper, lo hice pero dio error, revisar
  def title_for_page(page = nil) = page ? "#{page.to_s.capitalize} | #{@base_title}" : @base_title
    
end
