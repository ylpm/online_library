require "test_helper"

class CurrentUserSettingTest < ActionDispatch::IntegrationTest
  def setup
    @john = users(:john)
    login_as(@john)
  end
  
  # test "unsuccessful setting" do
  #   patch setting_me_path, params: {user: {person_attributes: { first_name: '1',
  #                                                              middle_name: '1',
  #                                                                last_name: '' },
  #                                                    username: '**',
  #                                                    password: 'foo',
  #                                       password_confirmation: 'bar'} },
  #                              xhr: true # xhr indica que se esta haciendo una solicitud AJAX
  #                                        # y que el controlador debe responder adecuadamente
  #                                        # en este caso con turbo stream
  #   assert_select 'div.alert-danger', count: 6
  # end
end
