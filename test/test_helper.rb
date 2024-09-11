ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    
    # def test_title_for_page(page = nil) = page ? "#{page.to_s.capitalize} | #{@base_title}" : @base_title
    
    def new_session_for(user, email_address: nil, persistent: false)
      raise ArgumentError, "Invalid user" unless user.instance_of? User
      raise ArgumentError, "Invalid email address" unless email_address.nil? || email_address.instance_of?(EmailAddress)
      new_session = user.sessions.create(email_address: email_address)
      new_session.remember if persistent
      session[:_sid] = new_session.id
      if new_session.remembered?
        cookies.permanent.encrypted[:_sid] = new_session.id
        cookies.permanent[:_rt] = new_session.remember_token
      end
      new_session
    end
    
    def is_logged_in?
      !session[:_sid].nil?
    end
  end
end

module ActionDispatch
  class IntegrationTest
    
    def login_as(user, password: 'Abcde123*', email_address: nil, remember_me: false)
      post login_path, params: {login: {identifier: email_address ? email_address : user.username,
                                          password: password,
                                       remember_me: remember_me ? '1' : '0'}}
    end 
    
  end
end
