class Session < ApplicationRecord
  belongs_to :user
  
  belongs_to :email_address, required: false, inverse_of: :sessions
  
  attr_reader :remember_token # attr_accessor :remember_token
  
  def login_identifier
    (email_address.address if email_address) || user.username
  end
    
  def remember
    set_session_digest
  end
  
  def forget
    if remembered?
      @remember_token = nil
      update_attribute(:session_digest, nil)
    end
  end
  
  def remembered?
    !session_digest.nil?
  end
  
  def forgotten?
    session_digest.nil?
  end
  
  def remembered_with?(remember_token)
    Session.token_match?(remember_token, session_digest)
  end
  
  def rescue_remember_token(remember_token)
    @remember_token = remember_token if remembered? && @remember_token.blank? && remembered_with?(remember_token)
  end
  
  private
  
  def set_session_digest
    # self.remember_token = Session.new_token
    @remember_token = Session.new_token
    update_attribute(:session_digest, Session.digest(remember_token))
    session_digest
  end
end
