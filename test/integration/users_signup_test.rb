require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
    get signup_path
    assert_response :success
    assert_no_difference 'User.count' do
      post users_path, params: {user: {person:{first_name: '1',
                                                last_name: '',
                                            email_address: {address: 'foo@'}},
                                     username: '**',
                                     password: 'foo',
                        password_confirmation: 'bar'}}
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select 'div#error_count'
    assert_select 'div.alert', 'The form contains 6 errors'
  end
  
  test "valid signup information" do
    get signup_path
    assert_response :success
    assert_difference 'User.count', 1 do
      post users_path, params: {user: {person: {first_name: 'John',
                                                 last_name: 'Johnson',
                                             email_address: {address: 'foo@bar.com'}},
                                     username: 'john',
                                     password: 'Abcde123*',
                        password_confirmation: 'Abcde123*'}}
    end
    assert_redirected_to User.last
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert_select 'div.alert-success', 'Welcome!'
  end
end
