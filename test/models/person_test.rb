require "test_helper"

class PersonTest < ActiveSupport::TestCase

  def setup
    # @test_person = Person.new first_name: "John", last_name: "Johnson"
    @test_person = people(:john)
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

