class Person < ApplicationRecord
  
  delegated_type :personable, types: %w[ User Author ], dependent: :destroy
  
  has_many :email_addresses, dependent: :destroy
  
  VALID_FIRST_NAME_REGEXP = /\A[a-z]{3,50}\Z/i.freeze # solo letras
  validates :first_name, presence: true,
                           # length: {minimum: 3, maximum: 50},
                           format: {with: VALID_FIRST_NAME_REGEXP }
                            
  # comienza con letra y puede contener espacios y giones, p.e., "De Varens", "Perez-Gonzalez". 
  # NO puede estar ausente pero puede ser de longitud 1
  VALID_LAST_NAME_REGEXP = /\A[a-z]([a-z\s\-]+)*\Z/i.freeze 
  validates :last_name, presence: true,
                          length: {maximum: 50},
                          format: {with: VALID_LAST_NAME_REGEXP }
    
   # EL MISMO FORMATO DE last_name, solo que
   # puede estar ausente, de ahi /\A(...)?\Z/i
   VALID_MIDDLE_NAME_REGEXP = /\A(#{VALID_LAST_NAME_REGEXP})?\Z/i.freeze 
   validates :middle_name, presence: false,
                             length: {maximum: 50},
                             format: {with: VALID_MIDDLE_NAME_REGEXP }
  
  validates :birthday, presence: false
  
  # validates :personable_type, presence: true # esta validacion no es necesaria puesto que la relacion 
                                               # delegated_type declarada al inicio ya exige la presencia 
                                               # de un personable.
  
  def full_name
    middle_name ? "#{first_name} #{middle_name} #{last_name}"
                : "#{first_name} #{last_name}"
  end
  
  def to_s = "#{self.full_name} <#{email_addresses.first}>"        
end
