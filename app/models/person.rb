class Person < ApplicationRecord
  
  delegated_type :personable, types: %w[User Author], dependent: :destroy
  
  has_many :email_addresses, inverse_of: :owner, dependent: :destroy
  accepts_nested_attributes_for :email_addresses
  
  VALID_FIRST_NAME_REGEXP = /\A[a-z]{3,50}\Z/i.freeze # solo letras
  validates :first_name, presence: true,
                           length: {minimum: 3, maximum: 50,
                                  too_short: "allows 3 chars minimum", 
                                   too_long: "allows 50 chars maximum"},
                           format: {with: VALID_FIRST_NAME_REGEXP, 
                                 message: "only allows letters" }
                            
  # comienza con letra y puede contener espacios y giones, p.e., "De Varens", "Perez-Gonzalez". 
  # NO puede estar ausente pero puede ser de longitud 1
  VALID_LAST_NAME_REGEXP = /\A[a-z]([a-z\s\-]+)*\Z/i.freeze 
  validates :last_name, presence: true,
                          length: {maximum: 50,
                                  too_long: "allows 50 chars maximum"},
                          format: {with: VALID_LAST_NAME_REGEXP, 
                                message: "uses letters, spaces and hyphens"  }
    
   # EL MISMO FORMATO DE last_name, solo que
   # puede estar ausente, de ahi /\A(...)?\Z/i
   VALID_MIDDLE_NAME_REGEXP = /\A(#{VALID_LAST_NAME_REGEXP})?\Z/i.freeze 
   validates :middle_name, presence: false,
                             length: {maximum: 50,
                                     too_long: "allows 50 chars maximum"},
                             format: {with: VALID_MIDDLE_NAME_REGEXP, 
                                   message: "only allows letters" }
  
  validates :birthday, presence: false,
                           with: :birthday_cannot_be_future
  
  # validates :personable_type, presence: true # esta validacion no es necesaria puesto que la relacion 
                                               # delegated_type declarada al inicio ya exige la presencia 
                                               # de un personable.
  
  def full_name
    middle_name ? "#{first_name} #{middle_name} #{last_name}"
                : "#{first_name} #{last_name}"
  end
  
  def to_s = "#{self.full_name} <#{email_addresses.first}>"
    
  private
  
  def birthday_cannot_be_future
    if birthday
      errors.add(:birthday, "can't be in the future") unless birthday <= Date.today
    end
  end
  
  def birthday_cannot_be_under_8_years
    if birthday
      errors.add(:birthday, "says you are under 8 years") unless birthday <= 8.years.ago
    end
  end     
end
