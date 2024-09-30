require "test_helper"

class PersonTest < ActiveSupport::TestCase  
  def setup
    @test_person = people(:john)
  end

  test "should be valid" do
    assert @test_person.valid?
    assert @test_person.errors.empty?
  end
end

class PresencePersonAttrsTest < PersonTest

  def setup
    super
    @blanks = {nil: nil, empty:'', whitespaces: '    '}
    @message_for_failing_test_of_presence = "should not be consider as present"
  end

  test "first name should be present" do
    @blanks.each do |key, value|
      @test_person.first_name = value
      assert_not @test_person.valid?, "The first name \"#{value}\" (blank) #{@message_for_failing_test_of_presence}"
      assert_not @test_person.errors[:first_name].empty?
      assert_equal "can't be blank", @test_person.errors[:first_name].first
    end
  end

  test "middle name should be optional" do
    @blanks.each do |key, value|
      @test_person.middle_name = value
      assert @test_person.valid?, "A nil middle name is permitted"
      assert @test_person.errors[:middle_name].empty?
    end
  end

  # test "middle name if present should not be a blank string" do
  #   @test_person.middle_name = @blank_string
  #   assert_not @test_person.valid?, "The middle name \"#{@test_person.middle_name}\" (blank) #{@message_for_failing_test_of_presence}"
  #   assert_not @test_person.errors[:middle_name].empty?
  #   assert_equal "only allows letters", @test_person.errors[:middle_name].first
  # end
  
  test "last name should be present" do
    @blanks.each do |key, value|
      @test_person.last_name = value
      assert_not @test_person.valid?, "The last name \"#{value}\" (blank) #{@message_for_failing_test_of_presence}"
      assert_not @test_person.errors[:last_name].empty?
      assert_equal "can't be blank", @test_person.errors[:last_name].first
    end
  end

  # test "last name should not be a blank string" do
  #   @test_person.last_name = @blank_string
  #   assert_not @test_person.valid?, "The last name \"#{@test_person.last_name}\" (blank) #{@message_for_failing_test_of_presence}"
  #   assert_not @test_person.errors[:last_name].empty?
  #   assert_equal "can't be blank", @test_person.errors[:last_name].first
  # end

  test "birthday should be optional" do
    @blanks.each do |key, value|
      @test_person.birthday = value
      assert @test_person.valid?, "A nil birthday means that it has not been set by the user"
      assert @test_person.errors[:birthday].empty?
    end
  end
  
  test "gender should be optional" do
    @blanks.each do |key, value|
      @test_person.gender = value
      assert @test_person.valid?, "A #{value} (nil) gender means that it has not been set by the user"
      assert @test_person.errors[:gender].empty?
    end
  end

  test "personable type (subclass) should be present" do
    @test_person.personable_type = ''
    assert_not @test_person.valid?, "The personable type attribute (subclass) can't be missing"
  end

  test "personable id should be present" do
    @test_person.personable = nil
    assert_not @test_person.valid?, "The personable id can't be missing"
  end
  
  test "primary email address should be optional" do
    @test_person.primary_email_address = nil
    assert @test_person.valid?, "The primary email address attribute can be missing"
  end
  
  test "should accept as primary an owned activated email address" do
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
    assert_not @test_person.errors[:primary_email_address].empty?
    assert_equal "must be activated", @test_person.errors[:primary_email_address].first
  end
  
  test "should not accept as primary an email address owned by somebody else" do
    mary_at_gmail = email_addresses(:mary_at_gmail)
    assert mary_at_gmail.activated?
    @test_person.primary_email_address = mary_at_gmail
    assert_not @test_person.valid?, "#{mary_at_gmail} should be rejected as primary. It doesn't belong to the person"
    assert_not @test_person.errors[:primary_email_address].empty?
    assert_equal "must be one of the #{@test_person.first_name}'s email addresses", @test_person.errors[:primary_email_address].first
  end
end

class LengthPersonAttrsTest < PersonTest

  def setup
    super
    @too_short_string = "F"
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
    @invalid_names = ["123", ".", ".F", "-Foo", "Foo-", "Fo-o"]
    @unclean_names = ["  Foo", "Foo  ", "  Foo  "]
  end

  test "should accept valid first names" do
    valid_names = ["Jean","Foo"+"o"*47]
    valid_names.each do |valid_name|
      @test_person.first_name = valid_name
      assert @test_person.valid?, "\"#{valid_name}\" should be a valid first name"
    end
  end
  
  test "should clean and accept unclean first names" do
    @unclean_names.each do |unclean_name|
      @test_person.first_name = unclean_name
      assert @test_person.valid?, "\"#{unclean_name}\" should be clean and accepted as a valid first name"
    end
  end

  test "should not accept invalid first names" do
    invalid_names = %w[F F. 123 1Fo Foo1 Fo_o]
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
  
  test "should clean and accept unclean middle names" do
    @unclean_names.each do |unclean_name|
      @test_person.middle_name = unclean_name
      assert @test_person.valid?, "\"#{unclean_name}\" should be clean and accepted as a valid middle name"
    end
  end

  test "should not accept invalid middle names" do
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
  
  test "should clean and accept unclean last names" do
    @unclean_names.each do |unclean_name|
      @test_person.last_name = unclean_name
      assert @test_person.valid?, "\"#{unclean_name}\" should be clean and accepted as a valid last name"
    end
  end

  test "should not accept invalid last names" do
    @invalid_names.each do |invalid_name|
      @test_person.first_name = invalid_name
      assert_not @test_person.valid?, "\"#{invalid_name}\" should be an invalid middle name"
    end
  end
  
  test "should not set a birthday format error when date format is [12]YYY-MM-DD" do
    %w(1000-01-01 1000-1-01 1000-01-1 9999-12-31).each do |valid_date|
      @test_person.birthday = valid_date
      @test_person.valid?
      assert_not_equal :invalid, @test_person.errors.first.type
      assert_equal :inclusion, @test_person.errors.first.type
    end
  end
  
  # test "should set a birthday format error when date format is not [1-9]YYY-MM-DD" do
  #   %w(999-1-1 10000-1-1 2000-0-1 2000-13-1 2000-1-00 2000-1-32).each do |invalid_date|
  #     @test_person.birthday = invalid_date
  #     assert_not @test_person.valid?, "#{invalid_date} should not be consider as valid"
  #     assert_not @test_person.errors[:birthday].empty?
  #     assert_equal :invalid, @test_person.errors.first.type
  #   end
  # end
  
  test "should accept birthday in range (120 years ago - today)" do
    valid_birthdays = [ Person::BIRTHDAYS[:OLDEST], 
                        Date.today.prev_year(100),
                        Date.today.prev_year(50),
                        Date.today.prev_year(20),
                        Date.today.prev_year(5),
                        Date.today.prev_year,
                        Date.today.prev_month(6),
                        Date.today.prev_month,
                        Date.today.prev_week,
                        Date.today.prev_day,
                        Date.today ]
    valid_birthdays.each do |valid_birthday|
      @test_person.birthday = valid_birthday
      assert @test_person.valid?, "#{valid_birthday} is in the birthday's permitted range"
      assert @test_person.errors[:birthday].empty?
    end
  end
  
  test "should not accept birthday out of range (120 years ago - today)" do
    invalid_birthdays = [ Person::BIRTHDAYS[:OLDEST].prev_day, Date.today.next_day ]
    invalid_birthdays.each do |invalid_birthday|
      @test_person.birthday = invalid_birthday
      assert_not @test_person.valid?, "#{invalid_birthday} should be out of the birthday's permitted range"
      assert_not @test_person.errors[:birthday].empty?
      assert_equal "must be between #{Person::BIRTHDAYS[:OLDEST]} and today",@test_person.errors[:birthday].first
    end
  end

  test "should accept valid genders" do
    Person::GENDERS.each do |valid_gender|
      @test_person.gender = valid_gender
      assert @test_person.valid?, "\"#{valid_gender}\" is a valid gender"
      assert @test_person.errors[:gender].empty?
    end
  end
  
  test "should clean and accept unclen valid genders" do
    ['  Man', 'Woman  ', '   Man   '].each do |unclean_gender|
      @test_person.gender = unclean_gender
      assert @test_person.valid?, "\"#{unclean_gender}\" should be clean and accept as a valid gender"
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

