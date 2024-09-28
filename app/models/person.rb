class Person < ApplicationRecord
  
  delegated_type :personable, types: %w[User Author], dependent: :destroy

  has_many :email_addresses, inverse_of: :owner, dependent: :destroy
  accepts_nested_attributes_for :email_addresses
    
  def registered_email_addresses = email_addresses.select{ |e| e.persisted? }
  
  def activated_email_addresses = email_addresses.where(activated: true)
  
  belongs_to :primary_email_address, class_name: "EmailAddress", optional: true
    
  validates :primary_email_address, with: :primary_email_address_belongs_to_the_person,
                                      if: -> { primary_email_address.present? }
  
  VALID_FIRST_NAME_REGEXP = /\A[a-z]{3,50}\Z/i.freeze # solo letras
  validates :first_name, presence: true,
                           length: { minimum: 3, maximum: 50,
                                   too_short: "allows 3 chars minimum",
                                    too_long: "allows 50 chars maximum" },
                           format: { with: VALID_FIRST_NAME_REGEXP, 
                                  message: "only allows letters" }
                            
  # comienza con letra y puede contener espacios y giones, p.e., "De Varens", "Perez-Gonzalez". 
  # NO puede estar ausente pero puede ser de longitud 1
  VALID_LAST_NAME_REGEXP = /\A[a-z]([a-z\s\-]+)*\Z/i.freeze 
  validates :last_name, presence: true,
                          length: { maximum: 50,
                                   too_long: "allows 50 chars maximum" },
                          format: { with: VALID_LAST_NAME_REGEXP, 
                                 message: "uses letters, spaces and hyphens"  }
    
   # EL MISMO FORMATO DE last_name, solo que
   # puede estar ausente, de ahi /\A(...)?\Z/i
   VALID_MIDDLE_NAME_REGEXP = /\A(#{VALID_LAST_NAME_REGEXP})?\Z/i.freeze
   validates :middle_name, length: { maximum: 50,
                                    too_long: "allows 50 chars maximum" },
                           format: { with: VALID_MIDDLE_NAME_REGEXP, 
                                  message: "only allows letters" }
  
  
  def full_name = "#{first_name} #{middle_name} #{last_name}".strip.gsub(/\s+/,?\s)
   
  def to_s = "#{self.full_name} <#{primary_email_address || email_addresses.first}>".strip
    
    
  BIRTHDAYS = { OLDEST: Date.new(120.years.ago.year, 1, 1), YOUNGEST: Date.today}
  BIRTHDAYS[:PERMITTED] = BIRTHDAYS[:OLDEST]..BIRTHDAYS[:YOUNGEST]
  BIRTHDAYS.freeze
  validates :birthday, inclusion: { in: BIRTHDAYS[:PERMITTED],
                               message: "must be between #{BIRTHDAYS[:OLDEST]} and today",
                                    if: -> { birthday.present? } }

  # enum gender: {
  #   Not_Specified: "Not Specified",
  #   Man: "Man",
  #   Woman: "Woman"
  # }
  # validates :gender, presence: true
  # def gender? = (self.gender.match?("Man") || self.gender.match?("Woman"))
  
  def gender=(g)
    super(g.nil? ? nil : g.downcase.capitalize)
  end
  
  GENDERS = Set.new(%w(Man Woman)).freeze
  
  validates :gender, inclusion: { in: GENDERS,
                             message: "is not a valid gender",
                                  if: -> { gender.present? } }
      
  # before_save :downcase_gender, if: -> { gender.present? }

  def primary_image # PROVISIONAL
    nil
  end
  
  # Sobreescribir el metodo destroy
  def destroy
    # Antes de eliminar la persona, limpiar la referencia de primary_email_address,
    # pues de lo contrario, al tratar de eliminar primero los email addresses asociadas,
    # si alguna esta establecida como la primary, no la podra eliminar y lanzara un error
    update_column(:primary_email_address_id, nil)
    super
  end
    
  private
  
  # # CUSTOM VALIDATORS
  def primary_email_address_belongs_to_the_person
    # if  primary_email_address_id.present?
     errors.add(:primary_email_address, "must be one of the #{first_name}'s email addresses") and return unless email_addresses.include?(primary_email_address)
     errors.add(:primary_email_address, "must be activated") unless primary_email_address.activated?
    # end
  end
  
  # def downcase_gender = self.gender.downcase!
  
  # def birthday_cannot_be_under_8_years
  #   if birthday
  #     errors.add(:birthday, "says you are under 8 years") unless birthday <= 8.years.ago
  #   end
  # end
end
