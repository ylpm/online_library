require "test_helper"

class SessionTest < ActiveSupport::TestCase
  def setup
    @john_most_recent_session = sessions(:john_most_recent_session)
  end
  
  test "should be valid" do
    assert @john_most_recent_session.valid?
    assert @john_most_recent_session.remembered?
  end
  
  test "should be associated to a user" do
    @john_most_recent_session.user = nil
    assert_not @john_most_recent_session.valid?, "A session have to belong a user"
  end

  test "login identifier should be an email address if email address identifier is set" do
    assert_equal email_addresses(:john_at_gmail).address, @john_most_recent_session.login_identifier
  end
  
  test "login identifier should be the username if email address identifier is NOT set" do
    @john_most_recent_session.email_address_identifier = nil
    assert @john_most_recent_session.valid?
    assert_equal users(:john).username, @john_most_recent_session.login_identifier
  end
  
  # test "order should be most recent first" do
  #   assert_equal @john_most_recent_session, Session.first
  # end
end

class SessionRememberingTest < SessionTest
  test "remember/forget mechanism" do
    @john_most_recent_session.forget
    assert_not @john_most_recent_session.remembered?
    assert @john_most_recent_session.forgotten?
    @john_most_recent_session.remember
    assert_not @john_most_recent_session.forgotten?
    assert @john_most_recent_session.remembered?
  end
  
  test "remember_with? should return true if remember token matches session digest" do
    assert @john_most_recent_session.remembered_with?('1234567')
  end
  
  test "remember_with? should return false if remember token doesn't matches session digest" do
    assert_not @john_most_recent_session.remembered_with?('abc')
    assert @john_most_recent_session.remembered?
  end
  
  test "remembered_with? method should return false if session digest is nil" do
    @john_most_recent_session.forget
    assert_not @john_most_recent_session.remembered_with?('')
    assert_not @john_most_recent_session.remembered?
    assert @john_most_recent_session.forgotten?
  end
  
  test "rescuing a session" do
    rescued_session = Session.rescue(@john_most_recent_session.id, '1234567')
    assert_equal @john_most_recent_session, rescued_session
    @john_most_recent_session.destroy
    rescued_session = Session.rescue(@john_most_recent_session.id, '1234567')
    assert rescued_session.nil?
  end
end
