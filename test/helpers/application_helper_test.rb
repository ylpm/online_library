require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  def setup
    @base_title = 'Online Library'
    @custom_title = 'This Page'
  end

  test 'full title should match the base title' do
    ['', '    '].each do |blank|
      assert_equal @base_title, full_title(blank), "Full title should be the same as base title since no page title was provided"
    end
  end
  
  test 'full title should match custom page title' do
    assert_equal "#{@custom_title} | #{@base_title}", full_title(@custom_title), "Full title should be \"#{@custom_title} | #{@base_title}\", since \"#{@custom_title}\" was provided as a page title"
  end
end