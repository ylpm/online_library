class User < ApplicationRecord
  include Personable
  
  has_many :sessions, dependent: :destroy
  
  before_destroy -> { self.sessions.destroy_all }, prepend: true  # Es necesario eliminar primero todas las sessiones asociadas
                                                                  # antes de destruir el usuario, porque si algunas de las sesiones
                                                                  # fueron abiertas con direccion de email en vez de con username,
                                                                  # entonces da error de integridad referencial, ya que, por el orden que
                                                                  # declaradas estan las asociaciones al inicio de la clase:
                                                                  # primero "include Personable" y luego "has_many :sessions", entonces
                                                                  # primero trata de eliminar las direcciones de email y luego las sesiones,
                                                                  # y como hay sesiones que tienen referencias a direcciones de email, entonces
                                                                  # da el error de integridad referencial.
                                                                    
  before_validation -> { self.username = username.blank? ? nil : username.strip.downcase }
  
  VALID_USERNAME_REGEXP = /\A[a-z]([\-\_\.]?[a-z\d]+)+\Z/i.freeze
  validates :username, presence: true,
                         length: { minimum: 3, too_short: "allows 3 chars minimum", 
                                   maximum: 30, too_long: "allows 30 chars maximum" },
                         format: { with: VALID_USERNAME_REGEXP, 
                                message: "starts with a letter and allows hyphens, dots and numbers after, p.e. john.doe"},
                         uniqueness: { case_sensitive: false }
  # before_save :downcase_username
  
  has_secure_password                       
  VALID_PASSWORD_REGEXP = /\A(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[\W]).{8,}$\z/.freeze
  validates :password, presence: true,
                         length: { minimum: 8,
                                 too_short: "allows 8 chars minimum"},
                         format: { with: VALID_PASSWORD_REGEXP,
                                message: "must have uppercase and lowercase letters, numbers, and special characters"} ,
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
