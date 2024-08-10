require "test_helper"

class UserTest < ActiveSupport::TestCase
  
  TEST_PASSWORD = "*Abc123*".freeze
  
  def setup
    # @test_user = users(:john)
    @test_user = Person.create(first_name: "Sample", 
                                last_name: "Person", 
                               personable: User.new(username:"sample_username", 
                                                    password: TEST_PASSWORD,
                                                    password_confirmation: TEST_PASSWORD)
                               ).user
  end

  test "user should be valid" do
    assert @test_user.valid?
  end
end

class UserCustomCreationTest < UserTest
  def setup
    @test_user = User.custom_create(first_name: "Another",
                                   middle_name: "Sample",
                                     last_name: "Person",
                                      username: "another_username",
                                      password: TEST_PASSWORD,
                                      password_confirmation: TEST_PASSWORD)
  end

  test "created user with custom create method should be valid" do
    assert @test_user.valid?
  end
end

class PresenceUserAttrsTest < UserTest
  def setup
    super
  end

  test "username should be present" do
    @test_user.username = ''
    assert_not @test_user.valid?, "The username \'#{@test_user.username}\' (empty string) should not be considered as present"
  end
  
  test "password should be present (nonblank)" do
    @test_user.password = @test_user.password_confirmation = ' ' * 8
    assert_not @test_user.valid?, "The password can't be blank"
  end
end

class LengthUserAttrsTest < UserTest
  def setup
    super
    @too_short_string = 'fo'
    @too_long_string = 'f' + 'o' * 30
  end

  test "username should not be too short" do
    @test_user.username = @too_short_string
    assert_not @test_user.valid?, "The username \"#{@test_user.username}\" (#{@test_user.username.length} chars) is too short"
  end

  test "username should not be too long" do
    @test_user.username = @too_long_string
    assert_not @test_user.valid?, "The username \"#{@test_user.username}\" (#{@test_user.username.length} chars) is too long"
  end
  
  test "password should not be too short" do
    @test_user.password = @test_user.password_confirmation = 'A1b2c3*' # lenght: 7
    assert_not @test_user.valid?, "The password \"#{@test_user.password}\" (#{@test_user.password.length} chars) is too short"
  end
  
  # test "password should not be too long" do
  #   @test_user.password = @test_user.password_confirmation = '*A1b2c3*' * 6 + 'xyz' # lenght: 51
  #   assert_not @test_user.valid?, "The password \"#{@test_user.password}\" (#{@test_user.password.length} chars) is too long"
  # end
end

class FormatUserAttrsTest < UserTest
  def setup
    super
  end

  test "username validation should accept valid usernames" do
    valid_usernames = [ "foo",
                        "foobar",
                        "foo123",
                        "foo1bar23",
                        "foo_bar",
                        "foo-bar",
                        "foo.bar",
                        "foo-123",
                        "foo_123",
                        "f1oo2.3ba_4r5-6" ]
    valid_usernames.each do |valid_username|
      @test_user.username = valid_username
      assert @test_user.valid?, "#{valid_username.inspect} is a valid username"
    end
  end

  test "username validation should not accept invalid username" do
    invalid_usernames = [ "fo",
                          "foo bar",
                          "foobar ",
                          " foobar",
                          "123foobar",
                          ".foobar",
                          "-foobar",
                          "_foobar",
                          "@foobar",
                          "foobar.",
                          "foobar-",
                          "foobar_",
                          "foo@bar" ]
    invalid_usernames.each do |invalid_username|
      @test_user.username = invalid_username
      assert_not @test_user.valid?, "#{invalid_username.inspect} is NOT a valid username"
    end
  end
  
  test "password validation should accept valid passwords" do
    valid_passwords = [ "User123*",
                        "123456-User",
                        "*User*123",
                        "#U1 s2 e3 r4#" ]
    valid_passwords.each do |valid_password|
      @test_user.password = @test_user.password_confirmation = valid_password
      assert @test_user.valid?, "#{valid_password.inspect} should be a valid password"
    end
  end
  
  test "password validation should not accept invalid passwords" do
    invalid_passwords = [ "User1234", 
                          "12345678",
                          "*User***",
                          "U S e R " ]
    invalid_passwords.each do |invalid_password|
      @test_user.password = @test_user.password_confirmation = invalid_password
      assert_not @test_user.valid?, "#{invalid_password.inspect} should be an invalid password"
    end
  end
end

class UniquenessUserAttrsTest < UserTest
  def setup
    super
  end

  test "username should be unique" do
    @duplicated_test_user = @test_user.dup
    @test_user.save
    # @duplicated_test_user.username.upcase! # ya no es necesario cuando se agrega el callback downcase_username
    assert_not @duplicated_test_user.valid?, "The username \'#{@duplicated_test_user.username}\' has been taken by another user before"
  end
end
