require "test_helper"

class PersonTest < ActiveSupport::TestCase
  
  TEST_PASSWORD = "*Abc123*".freeze
  
  def setup
    # @test_person = Person.new first_name: "John", last_name: "Johnson"
    # @test_person = people(:john)
    @test_person = Person.create(first_name: "Sample", 
                                last_name: "Person", 
                               personable: User.new(username:"sample_username", 
                                                    password: TEST_PASSWORD,
                                                    password_confirmation: TEST_PASSWORD))
  end

  test "should be valid" do
    assert @test_person.valid?
  end
end

class PresencePersonAttrsTest < PersonTest

  def setup
    super
    @blank_string = "   "
    @message_for_failing_test_of_presence = "should not be consider as present"
  end

  test "first name should be present" do
    @test_person.first_name = @blank_string
    assert_not @test_person.valid?, "The first name \"#{@test_person.first_name}\" (blank) #{@message_for_failing_test_of_presence}"
  end

  test "middle name can be missing" do
    @test_person.middle_name = ''
    assert @test_person.valid?, "The middle name can be missing"
  end

  test "middle name should not be blank" do
    @test_person.middle_name = @blank_string
    assert_not @test_person.valid?, "The middle name, if present, should not be a blank string"
  end

  test "last name should be present" do
    @test_person.last_name = @blank_string
    assert_not @test_person.valid?, "The last name \"#{@test_person.last_name}\" (blank) #{@message_for_failing_test_of_presence}"
  end

  test "birthday can be missing" do
    @test_person.birthday = nil
    assert @test_person.valid?, "The birthday attribute can be missing"
  end
  
  test "personable type (subclass) should be present" do
    @test_person.personable_type = ''
    assert_not @test_person.valid?, "The personable type attribute (subclass) can't be missing"
  end
  
  test "personable id should be present" do
    @test_person.personable = nil
    assert_not @test_person.valid?, "The personable id can't be missing"
  end
end

class LengthPersonAttrsTest < PersonTest

  def setup
    super
    @too_short_string = "Jo"
    @message_for_failing_test_of_too_short_length = "(#{@too_short_string.length} chars) is too short"
    @too_long_string = "Foo" + "o" * 48
    @message_for_failing_test_of_too_long_length = "(#{@too_long_string.length} chars) is too long"
  end

  test "first name lenght should be 2 or more" do
    @test_person.first_name = @too_short_string
    assert_not @test_person.valid?, "The first name \"#{@test_person.first_name}\" #{@message_for_failing_test_of_too_short_length}"
  end

  test "first name lenght should be lesser than 51 chars" do
    @test_person.first_name = @too_long_string
    assert_not @test_person.valid?, "The first name \"#{@test_person.first_name}\" #{@message_for_failing_test_of_too_long_length}"
  end

  test "middle name lenght should be lesser than 51 chars" do
    @test_person.middle_name = @too_long_string
    assert_not @test_person.valid?, "The middle name \"#{@test_person.middle_name}\" #{@message_for_failing_test_of_too_long_length}"
  end

  test "last name lenght should be lesser than 51 chars" do
    @test_person.last_name = @too_long_string
    assert_not @test_person.valid?, "The last name \"#{@test_person.last_name}\" #{@message_for_failing_test_of_too_long_length}"
  end
end

class FormatPersonAttrsTest < PersonTest
  def setup
    super
    @valid_names = ["Pierre", "De Maria", "De La Rosa", "Jose-Maria", "M"]
    @invalid_names = ["123", ".", ".F", "-Foo", " Foo"]
  end
  
  test "should accept valid first names" do
    valid_names = ["Jean","Foo"+"o"*47]
    valid_names.each do |valid_name|
      @test_person.first_name = valid_name
      assert @test_person.valid?, "\"#{valid_name}\" should be a valid first name"
    end
  end
  
  test "should reject invalid first names" do
    invalid_names = %w[Fo Fo. 123 1Fo Foo1 Fo_o]
    invalid_names.each do |invalid_name|
      @test_person.first_name = invalid_name
      assert_not @test_person.valid?, "\"#{invalid_name}\" should be an invalid first name"
    end
  end
  
  test "should accept valid middle names" do
    @valid_names.each do |valid_name|
      @test_person.middle_name = valid_name
      assert @test_person.valid?, "\"#{valid_name}\" should be a valid middle name"
    end
  end
  
  test "should reject invalid middle names" do
    @invalid_names.each do |invalid_name|
      @test_person.first_name = invalid_name
      assert_not @test_person.valid?, "\"#{invalid_name}\" should be an invalid middle name"
    end
  end
  
  test "should accept valid last names" do
    @valid_names.each do |valid_name|
      @test_person.middle_name = valid_name
      assert @test_person.valid?, "\"#{valid_name}\" should be a valid middle name"
    end
  end
  
  test "should reject invalid last names" do
    @invalid_names.each do |invalid_name|
      @test_person.first_name = invalid_name
      assert_not @test_person.valid?, "\"#{invalid_name}\" should be an invalid middle name"
    end
  end
end

class AssociatedEmailAddressesDestructionTest < PersonTest
  def setup
    @test_person = Person.new(first_name: "Example", last_name: "User", personable: User.new(username: "xdffgt34r_0ooi",
                                                                                             password: TEST_PASSWORD,
                                                                                             password_confirmation: TEST_PASSWORD))
  end
  
  test "associated email addresses should be destroyed" do
    @test_person.save
    @test_person.email_addresses.create(address: "h66trtlop01@example.com")
    assert_difference 'EmailAddress.count', -1 do
      @test_person.destroy
    end
  end
end

