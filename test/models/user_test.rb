require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @test_user = users(:john)
  end

  test "fixture user should be valid" do
    assert @test_user.valid?
  end
end

class UserCreationTest < UserTest
  def setup
    @test_user = Person.create(first_name: "Sample", last_name: "Person", personable: User.new(username:"sample_username")).user
  end
  
  test "created user should be valid" do
    assert @test_user.valid?
  end
  
  test "created user with custom create method should be valid" do
    @test_user = User.custom_create(first_name: "Another", middle_name: "Sample", last_name: "Person", username:"another_username")
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
