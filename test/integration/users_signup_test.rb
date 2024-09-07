require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
    get signup_path
    assert_response :success
    assert_no_difference 'User.count' do
      post users_path, params: {user: {person:{first_name: '1',
                                              middle_name: '123',
                                                last_name: '',
                                                 birthday: 5.years.from_now, # nacimiento en el futuro
                                            email_address: {address: 'foo@'}},
                                     username: '**',
                                     password: 'foo',
                        password_confirmation: 'bar'}},
                        xhr: true # xhr indica que la respuesta es con turbo stream
    end
    assert_not is_logged_in?
    assert_select 'div#error_count'
    assert_select 'div.alert', 'The form contains 8 errors'
  end
  
  test "valid signup information" do
    get signup_path
    assert_response :success
    assert_difference 'Session.count', 1 do
      assert_difference 'User.count', 1, "A new user should be signed up" do
        post users_path, params: {user: {person: {first_name: 'Example',
                                                   last_name: 'User',
                                               email_address: {address: 'user@example.com'}},
                                       username: 'example_user',
                                       password: 'Abcde123*',
                          password_confirmation: 'Abcde123*'}}
      end
    end
    assert is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_template 'static_pages/home'
    assert_not flash.empty?
    assert_select 'div.alert-success', 'Welcome!'
  end
end
