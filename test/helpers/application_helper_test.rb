require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  def setup
    @base_title = 'Sample App'
    @custom_title = 'This Page'
  end

  test 'should match the base title' do
    assert_equal @base_title, full_title, "Full title should be the same as base title since no page title was provided"
  end
  
  test 'should match customized page title' do
    assert_equal "#{@custom_title} | #{@base_title}", full_title(@custom_title), "Full title should be \"#{@custom_title} | #{@base_title}\", since \"#{@custom_title}\" was provided as a page title"
  end
end