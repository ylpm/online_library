class User < ApplicationRecord
  include Personable
  
  has_many :sessions, dependent: :destroy
  
  
  VALID_USERNAME_REGEXP = /\A[a-z]([\-\_\.]?[a-z\d]+)+\Z/i.freeze
  validates :username, presence: true,
                         length: { minimum: 3, too_short: "allows 3 chars minimum", 
                                   maximum: 30, too_long: "allows 30 chars maximum" },
                         format: { with: VALID_USERNAME_REGEXP, 
                                message: "starts with a letter and allows hyphens, dots and numbers after, p.e. john.doe"},
                         uniqueness: { case_sensitive: false }
  before_save :downcase_username
  
  has_secure_password                       
  VALID_PASSWORD_REGEXP = /\A(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[\W]).{8,}$\z/.freeze
  validates :password, presence: true,
                         length: { minimum: 8,
                                 too_short: "allows 8 chars minimum"},
                         format: { with: VALID_PASSWORD_REGEXP, 
                                message: "must have uppercase and lowercase letters, numbers, and special characters"} ,
                      allow_nil: true
  
  
  
  
  # esto que sigue no es necesario,
  # pq has_secure_password se encarga de hacerlo,
  # y esa es la razon por la cual siempre se verifica que
  # el password coincida con el password_confirmation,
  # porque has_secure_password obliga a que se ejecute
  # la validacion de confirmacion sobre el password
  # mediante validates :password_confirmation, presence: true.
  # (Poner esta explicacion en el documento sobre las validaciones)
  
  # validates :password_confirmation, presence: true,
  #                                         if: -> { password.present? },
  #                                  allow_nil: true
  
  
  
  
  

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
    # pero no es confiable delegar en esto.
    self.sessions.destroy_all # self.sessions.each {|s| s.destroy}
    super
  end

  # def to_s = "#{self.person.first_name} #{self.person.last_name} <#{self.username}>"
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


  private
  
  def downcase_username = self.username.downcase!
    
end
