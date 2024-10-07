class Person < ApplicationRecord
  
  delegated_type :personable, types: %w[User Author], dependent: :destroy
  
  has_many :email_addresses, inverse_of: :owner, dependent: :destroy #, before_add: :check_email_address_repetitions
  accepts_nested_attributes_for :email_addresses
  
  belongs_to :primary_email_address, class_name: "EmailAddress", optional: true
  
  validates :primary_email_address, with: :primary_email_address_must_belong_to_the_person_and_be_activated, 
                                    allow_nil: true
                                    
  before_destroy -> { update_column(:primary_email_address_id, nil) }, prepend: true
   
  scope :with_primary_email_address, -> { where("primary_email_address_id IS NOT NULL") }
  scope :without_primary_email_address, -> { where(primary_email_address_id: nil) }
  # validates :primary_email_address, inclusion: { in: -> { activated_email_addresses },
  #                                           message: "must be one of the #{first_name}'s activated email addresses",
  #                                                if: -> { primary_email_address.present? } }

  before_validation :normalize_attributes
  
  VALID_FIRST_NAME_REGEXP = /\A[a-z]{2,50}\Z/i.freeze # solo letras
  validates :first_name, presence: true,
                           length: { minimum: 2, too_short: "allows %{count} chars minimum",
                                     maximum: 50, too_long: "allows %{count} chars maximum" },
                           format: { with: VALID_FIRST_NAME_REGEXP, 
                                  message: "only allows letters" }
         
  # Comienza con letra y puede contener espacios y guiones, p.e., "von Neumann", "Perez-Gonzalez". 
  # NO puede estar ausente pero puede ser de longitud 1
  VALID_LAST_NAME_REGEXP = /\A[a-z]([a-z\s\-]+)*\Z/i.freeze 
  validates :last_name, presence: true,
                          length: { maximum: 50, too_long: "allows %{count} chars maximum" },
                          format: { with: VALID_LAST_NAME_REGEXP, 
                                 message: "uses letters, spaces and hyphens"  }
                                 
  # EL MISMO FORMATO DE last_name, excepto que puede estar ausente: ...?\Z/
  # VALID_MIDDLE_NAME_REGEXP = /\A(#{VALID_LAST_NAME_REGEXP})?\Z/i.freeze
  validates :middle_name, length: { maximum: 50, too_long: "allows %{count} chars maximum" },
                          format: { with: VALID_LAST_NAME_REGEXP,
                                 message: "only allows letters" },
                       allow_nil: true


  def full_name = "#{first_name} #{middle_name} #{last_name}".strip.gsub(/\s+/,?\s)

   
  def to_s = full_name # "#{self.full_name} <#{primary_email_address || email_addresses.first}>".strip

  
  DATE_REGEXP = /\A[1-9][\d]{3}\-((0?[1-9])|(1[012]))\-((0?[1-9])|([12]?\d)|(3[01]))\Z/.freeze
  
  BIRTHDAYS = { OLDEST: Date.new(120.years.ago.year, 1, 1), YOUNGEST: Date.today }
  BIRTHDAYS[:PERMITTED] = BIRTHDAYS[:OLDEST]..BIRTHDAYS[:YOUNGEST]
  BIRTHDAYS.freeze
                
  validates :birthday, format: { with: DATE_REGEXP,
                              message: "invalid date" },
                    inclusion: { in: BIRTHDAYS[:PERMITTED],
                            message: "must be between #{BIRTHDAYS[:OLDEST]} and today" },   
                    allow_nil: true
                    
  # enum gender: {
  #   Not_Specified: "Not Specified",
  #   Man: "Man",
  #   Woman: "Woman"
  # }
  # validates :gender, presence: true
  # def gender? = (self.gender.match?("Man") || self.gender.match?("Woman"))
  
  # def gender=(g)
  #   super(g.nil? ? nil : g.downcase.capitalize)
  # end
  
  GENDERS = Set.new(%w(Man Woman)).freeze
  
  validates :gender, inclusion: { in: GENDERS,
                             message: "is not a valid gender" },
                     allow_nil: true
  
  GENDERS.each do |g|
    scope ActiveSupport::Inflector.pluralize(g.downcase).to_sym, -> { where(gender: g) }
  end
  scope :no_gender, -> { where(gender: nil) }
  
  def primary_image = nil # PROVISIONAL
    
  private
  
  # def check_email_address_repetitions(email_address)
  #   self.email_addresses.each do |email|
  #     if email.address.match?(/\A#{email_address.address}\z/i)
  #       # self.errors.add(:email_addresses, "you are already using this email address")
  #       throw(:abort)
  #     end
  #   end
  # end
  
  # Triggered by before_validation callback
  def normalize_attributes
    self.first_name = first_name.blank? ? nil : first_name.strip
    self.middle_name = middle_name.blank? ? nil : middle_name.strip
    self.last_name = last_name.blank? ? nil : last_name.strip
    self.gender =  gender.blank? ? nil : gender.strip.downcase.capitalize # titleize no puede ser usado en lugar de donwncase.capitalize
                                                                          # porque en caso de que se entren valores como 'maN', titleize
                                                                          # devuelve 'Ma N'
  end
    
  
  # # CUSTOM VALIDATORS
  def primary_email_address_must_belong_to_the_person_and_be_activated
    if primary_email_address_id.present?
     errors.add(:primary_email_address, "must be one of the #{first_name}'s email addresses") and return unless email_addresses.include?(primary_email_address)
     errors.add(:primary_email_address, "must be activated") unless primary_email_address.activated?
    end
  end

end
