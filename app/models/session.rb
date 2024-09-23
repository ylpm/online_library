class Session < ApplicationRecord
  belongs_to :user, inverse_of: :sessions
  
  belongs_to :email_address_identifier, required: false, 
                                        class_name: 'EmailAddress',
                                        foreign_key: :email_address_id,
                                        inverse_of: :identified_sessions
                                        
  
  attr_reader :remember_token
  
  def login_identifier
    (email_address_identifier.address if !email_address_identifier.nil?) || user.username
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
    @remember_token = Session.new_token
    update_attribute(:session_digest, Session.digest(remember_token))
    session_digest
  end
end
