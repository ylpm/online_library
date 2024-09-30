class Session < ApplicationRecord  
  belongs_to :user, inverse_of: :sessions
  
  belongs_to :email_address_identifier, required: false, 
                                        class_name: 'EmailAddress',
                                        foreign_key: :email_address_id,
                                        inverse_of: :identified_sessions
  
  scope :username_based, -> { where(email_address_id: nil) }
  scope :email_address_based, -> { where("email_address_id IS NOT NULL") }
  scope :forgotten, -> { where(session_digest: nil) }
  scope :remembered, -> { where("session_digest IS NOT NULL") }
  
  
  attr_reader :remember_token
  
  def login_identifier
    return email_address_identifier.address unless email_address_identifier.nil?
    user.username
    # (email_address_identifier.address if !email_address_identifier.nil?) || user.username
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
  
  def Session.rescue(id, token)
    rescued_session = Session.find_by_id(id)
    if rescued_session&.remembered_with?(token)
      return rescued_session
    end
    nil
  end
  
  def remembered_with?(remember_token)
    if Session.token_match?(remember_token, session_digest)
      @remember_token = remember_token
      return true
    end
    false
  end
  
  # def rescue_remember_token(remember_token)
  #   @remember_token = remember_token if remembered? && @remember_token.blank? && remembered_with?(remember_token)
  # end
  
  private
  
  def set_session_digest
    @remember_token = Session.new_token
    update_attribute(:session_digest, Session.digest(remember_token))
    session_digest
  end
end
