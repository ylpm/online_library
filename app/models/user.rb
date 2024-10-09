class User < ApplicationRecord
  include Personable
  
  has_many :sessions, inverse_of: :user #, dependent: :destroy
  
  before_destroy -> { self.sessions.destroy_all }, prepend: true
                                                                    
  before_validation -> { self.username = username.blank? ? nil : username.strip.downcase }
  
  validates :username, presence: true,
                       profanity: true,
                       username_format: true,
                       length: { minimum: 3, too_short: "allows 3 chars minimum", 
                                 maximum: 30, too_long: "allows 30 chars maximum" },
                       uniqueness: { case_sensitive: false }
  
  has_secure_password                       
  
  validates :password, presence: true,
                       password_format: true,
                       length: { minimum: 8, too_short: "allows 8 chars minimum"},
                       allow_nil: true

  def to_s = "#{self.person.full_name} <#{self.username}>"
  
  # Find user for authentication
  # def User.find_by_login(arg)
  #   raise ArgumentError, "Argument must be a String, not a #{arg.class}" unless arg.instance_of? String
  #
  #   unless arg.blank?
  #     arg.downcase!
  #     if user = find_by_username(arg)
  #       return user
  #     elsif email = EmailAddress.find_by_address(arg)
  #       return email.owner.user if email.activated?
  #     end
  #   end
  # end
    
end
