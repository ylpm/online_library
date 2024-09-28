require "test_helper"

class PersonTest < ActiveSupport::TestCase  
  def setup
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

  test "middle name if present should not be blank string" do
    @test_person.middle_name = @blank_string
    assert_not @test_person.valid?, "The middle name \"#{@test_person.middle_name}\" (blank) #{@message_for_failing_test_of_presence}"
  end

  test "last name should be present" do
    @test_person.last_name = @blank_string
    assert_not @test_person.valid?, "The last name \"#{@test_person.last_name}\" (blank) #{@message_for_failing_test_of_presence}"
  end

  test "birthday can be missing" do
    @test_person.birthday = nil
    assert @test_person.valid?, "The birthday attribute can be missing"
  end

  test "should accept birthday in range (120 years ago - today)" do
    valid_birthdays = [Person::BIRTHDAY_RANGE.min, 6.months.ago.to_date, Person::BIRTHDAY_RANGE.max]
    valid_birthdays.each do |valid_birthday|
      @test_person.birthday = valid_birthday
      assert @test_person.valid?, "#{valid_birthday} is in the birthday's permitted range"
      assert @test_person.errors[:birthday].empty?
    end
  end
  
  test "should not accept birthday out of range (120 years ago - today)" do
    invalid_birthdays = [121.years.ago.to_date, 1.day.from_now.to_date]
    invalid_birthdays.each do |invalid_birthday|
      @test_person.birthday = invalid_birthday
      assert_not @test_person.valid?, "#{invalid_birthday} is out of the birthday's permitted range"
      assert_not @test_person.errors[:birthday].empty?
      assert_equal "must be between 120 years ago and today",@test_person.errors[:birthday].first
    end
  end
  
  # test "birthday should not be future" do
  #   @test_person.birthday = 1.day.from_now
  #   assert_not @test_person.valid?, "The birthday attribute can't be after today #{Date.today})"
  #   assert_not @test_person.errors[:birthday].empty?
  #   assert_equal "can't be in the future",@test_person.errors[:birthday].first
  # end
  #
  # test "birthday should not be previous 120 years ago" do
  #   @test_person.birthday = 121.years.ago
  #   assert_not @test_person.valid?, "The birthday attribute can't be previous to 120 years ago"
  #   assert_not @test_person.errors[:birthday].empty?
  #   # assert_equal "can't be previous to 120 years ago",@test_person.errors[:birthday].first
  #   assert_equal "must be between 120 years ago and today",@test_person.errors[:birthday].first
  # end
  
  test "gender can be missing" do
    @test_person.gender = nil
    assert @test_person.valid?, "The gender attribute can be nil"
    assert @test_person.errors[:gender].empty?
  end

  test "personable type (subclass) should be present" do
    @test_person.personable_type = ''
    assert_not @test_person.valid?, "The personable type attribute (subclass) can't be missing"
  end

  test "personable id should be present" do
    @test_person.personable = nil
    assert_not @test_person.valid?, "The personable id can't be missing"
  end
  
  test "primary email address can be missing" do
    @test_person.primary_email_address = nil
    assert @test_person.valid?, "The primary email address attribute can be missing"
  end
  
  test "should accept as primary only an owned activated email address" do
    john_at_hey = email_addresses(:john_at_hey)
    assert john_at_hey.activated?
    @test_person.primary_email_address = john_at_hey
    assert @test_person.valid?, "#{john_at_hey} should be accepted as primary. It belongs to the person and is activated"
  end
  
  test "should not accept as primary an owned email address which is not activated" do
    john_at_aol = email_addresses(:john_at_aol)
    assert_not john_at_aol.activated?
    @test_person.primary_email_address = john_at_aol
    assert_not @test_person.valid?, "#{john_at_aol} should be rejected as primary. It belogns to the person but is not activated"
    assert_equal "must be activated", @test_person.errors[:primary_email_address].first
  end
  
  test "should not accept as primary an email address owned by somebody else" do
    mary_at_gmail = email_addresses(:mary_at_gmail)
    assert mary_at_gmail.activated?
    @test_person.primary_email_address = mary_at_gmail
    assert_not @test_person.valid?, "#{mary_at_gmail} should be rejected as primary. It doesn't belog to the person"
    assert_equal "must be one of the #{@test_person.first_name}'s email addresses", @test_person.errors[:primary_email_address].first
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

  test "should accept valid genders" do
    Person::GENDERS.each do |valid_gender|
      @test_person.gender = valid_gender
      assert @test_person.valid?, "\"#{@test_person.gender}\" is a valid gender"
      assert @test_person.errors[:gender].empty?
    end
  end
  
  test "should accept valid gender variants" do
    Person::GENDERS.each do |valid_gender|
      @test_person.gender = valid_gender.upcase
      assert @test_person.valid?, "\"#{valid_gender.upcase}\" is a valid gender"
      assert @test_person.errors[:gender].empty?
    end
  end

  test "should not accept invalid genders" do
    invalid_genders = ["invalid", "Other Gender",]
    invalid_genders.each do |invalid_gender|
      @test_person.gender = invalid_gender
      assert_not @test_person.valid?, "\"#{invalid_gender}\" should not be a valid gender"
      assert_not @test_person.errors[:gender].empty?
      assert_equal "is not a valid gender", @test_person.errors[:gender].first
    end
  end

end

class AssociatedEmailAddressesDestructionTest < PersonTest
  
  test "associated email addresses should be destroyed" do
    @test_person.save
    assert_difference 'EmailAddress.count', -@test_person.email_addresses.length do
      @test_person.personable.destroy
    end
  end
  
end

