class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  
  # Returns the hash digest of the given string.
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST 
                                                : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  def self.new_token
    SecureRandom.urlsafe_base64
  end
  
  def self.token_match?(token, digest)
    digest.blank? ? false : BCrypt::Password.new(digest).is_password?(token)
  end
end
