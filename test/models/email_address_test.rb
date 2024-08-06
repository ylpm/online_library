require "test_helper"

class EmailAddressTest < ActiveSupport::TestCase
  def setup
    @test_email = email_addresses(:john_at_hey)
  end
  
  test "should be valid" do
    assert @test_email.valid?
  end
  
end

class PresenceEmailAddressAttrsTest < EmailAddressTest
  def setup
    super
    
  end
  
  test "address should not be nil" do
    @test_email.address = nil
    assert_not @test_email.valid?
  end
  
  test "address should not be empty" do
    @test_email.address = ''
    assert_not @test_email.valid?
  end
  
  test "address should not be blank" do
    @test_email.address = '   '
    assert_not @test_email.valid?
  end
end

class LengthEmailAddressAttrsTest < EmailAddressTest
  def setup
    super
    @too_long_email_address = "foo" + "o" * 241 + "@example.com"
    @message_for_failing_test_of_too_long_length = "#{@too_long_email_address} chars) is too long" 
  end

  test "email address should not be too long" do
    @test_email.address = @too_long_email_address
    assert_not @test_email.valid?, "The email address \"#{@test_email.address}\" #{@message_for_failing_test_of_too_long_length}"
  end
end

class FormatEmailAddressAttrsTest < EmailAddressTest
  def setup
    super
  end
  
  test "email validation should accept valid addresses" do
    valid_addresses = %w[ user@example.com 
                          USER@foo.COM 
                          User01@bar.com
                          A_US-ER@foo.bar.org
                          first.last@foo.jp 
                          foo+bar@baz.cn ]
    valid_addresses.each do |valid_address|
      @test_email.address = valid_address
      assert @test_email.valid?, "\"#{@test_email.address}\" should be a valid email address"
    end
  end
  
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[ user
                            user.
                            user.com
                            user,com
                            user@
                            user@-
                            user@com
                            user@.com
                            user@example..com
                            user@example.c
                            user@example,com
                            user@foo_bar.com
                            user@foo+bar.com
                            123@example.com
                            1user@example.com
                            *user@example.com
                            user*@example.com 
                            us*er@example.com
                            @example.com
                            .@example.com 
                            +@example.com
                            -@example.com
                            _@example.com ]  
    invalid_addresses.each do |invalid_address|
      @test_email.address = invalid_address
      assert_not @test_email.valid?, "\"#{@test_email.address}\" should be an invalid email address"
    end
  end
end

class UniquenessEmailAddressAttrsTest < EmailAddressTest
  def setup
    super
    # @test_person = people(:john)
  end
  
  test "email address should be unique" do
    duplicated_test_email = @test_email.dup
    # duplicated_test_email.address.upcase!
    @test_email.save 
    # duplicated_test_email.address.upcase!
    assert_not duplicated_test_email.valid?
  end

end
