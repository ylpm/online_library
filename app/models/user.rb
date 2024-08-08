class User < ApplicationRecord
  include Personable
  
  before_save :downcase_username
  
  VALID_USERNAME_FORMAT = /\A[a-z]([\-\_\.]?[a-z\d]+)+\Z/i.freeze
  validates :username, presence: true,
                         length: { minimum: 3, maximum: 30 }, # se puede incluir en el formato, y se quita de aqui
                         format: { with: VALID_USERNAME_FORMAT },
                         uniqueness: true # { case_sensitive: false } # no es necesario cuando se añade el callback downcase_username
                         
  private
  
  def downcase_username = self.username.downcase!
    
end
