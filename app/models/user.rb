class User < ApplicationRecord
  include Personable
  
  has_many :sessions, dependent: :destroy
  
  has_secure_password # requires a password_digest field at database level users table and the bcrypt gem
                      # adds two virtual attributes to User model: password and password_confirmation
  
  before_save :downcase_username
  
  VALID_USERNAME_REGEXP = /\A[a-z]([\-\_\.]?[a-z\d]+)+\Z/i.freeze
  validates :username, presence: true,
                         length: { minimum: 3, maximum: 30,
                                 too_short: "allows 3 chars minimum", 
                                  too_long: "allows 30 chars maximum" },
                         format: { with: VALID_USERNAME_REGEXP, 
                                message: "starts with a letter and allows hyphens, dots and numbers after, p.e. john.doe"},
                         uniqueness: true # { case_sensitive: false } esto no es necesario cuando se añade el callback downcase_username
                         
  VALID_PASSWORD_REGEXP = /\A(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[\W]).{8,}$\z/
  validates :password, presence: true,
                         length: { minimum: 8,
                                 too_short: "allows 8 chars minimum"},
                         format: { with: VALID_PASSWORD_REGEXP, 
                                message: "must have uppercase and lowercase letters, numbers, and special characters"} ,
                      allow_nil: true
  validates :password_confirmation, presence: true,
                                          if: -> { password.present? },
                                   allow_nil: true

  # Sobreescribir el destroy
  def destroy
    # Es necesario eliminar primero todas las sessiones asociadas
    # antes de destruir el usuario, porque si algunas de las sesiones
    # fueron abiertas con direccion de email en vez de con username,
    # entonces da error de integridad referencial, ya que, por el orden que
    # declaradas estan las asociaciones al inicio de la clase:
    # primero "include Personable" y luego "has_many :sessions", entonces
    # primero trata de eliminar las direcciones de email y luego las sesiones,
    # y como hay sesiones que tienen referencias a direcciones de email, entonces
    # da el error de integridad referencial. Una forma de resolverlo
    # es declarando primero  "has_many :sessions" y luego "include Personable"
    # pero no es confiable descansar en esto.
    self.sessions.each {|s| s.destroy}
    super
  end

  def to_s = "#{self.person.first_name} #{self.person.last_name} <#{self.username}>"
  
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


  private
  
  def downcase_username = self.username.downcase!
    
end
