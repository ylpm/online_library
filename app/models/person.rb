class Person < ApplicationRecord
  
  delegated_type :personable, types: %w[User Author], dependent: :destroy

  has_many :email_addresses, inverse_of: :owner, dependent: :destroy
  accepts_nested_attributes_for :email_addresses
  
  belongs_to :primary_email_address, class_name: "EmailAddress", optional: true
    
  def primary_image # PROVISIONAL
    nil
  end
  
  enum gender: {
      Not_Specified: "Not Specified",
      Man: "Man",
      Woman: "Woman"
    }
    
  def gender? = (self.gender.match?("Man") || self.gender.match?("Woman"))
  
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
                           
  validates :gender, presence: true
  
  validates :primary_email_address, presence: false,
                                        with: :primary_email_address_must_belong_to_the_person
  
  def full_name
    middle_name ? "#{first_name} #{middle_name} #{last_name}"
                : "#{first_name} #{last_name}"
  end
  
  def to_s = "#{self.full_name} <#{email_addresses.first}>"
  
  # Sobreescribir el metodo destroy
  def destroy
    # Antes de eliminar la persona, limpiar la referencia de primary_email_address
    # llamo update_column en lugar de update_attribute o simplemente update
    # para circunvalar las validaciones y actualizar 
    update_column(:primary_email_address_id, nil)
    super
  end
    
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
  
  def primary_email_address_must_belong_to_the_person
    if primary_email_address_id.present?
      errors.add(:primary_email_address, "must be one of the #{first_name}'s email addresses") unless email_addresses.include?(primary_email_address)
    end
  end
end
