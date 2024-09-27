class EmailAddress < ApplicationRecord
  belongs_to :owner, class_name: 'Person', inverse_of: :email_addresses, required: true
  
  # has_one :owner_marked_as_primary, required: false,
  #                                   class_name: 'Person',
  #                                   foreign_key: :primary_email_address_id,
  #                                   inverse_of: :primary_email_address
  
  has_many :identified_sessions, class_name: 'Session', inverse_of: :email_address_identifier
  
  default_scope -> { includes(:owner).order(created_at: :asc) } # al recuperar las direcciones de email, 
                                                                # se recucuperan tambien su owner,
                                                                # y las direcciones se recuperan en el mismo orden en que fueron creadas.
                                                                # Para mejorar rendimiento, indexar la columna created_at
  
  def primary?
    # !owner_marked_as_primary.nil?
    owner.primary_email_address.eql?(self)
  end
      
  before_save :downcase_address
  before_save :activate_email_address # provisional
  
  VALID_EMAIL_FORMAT = /\A[a-z][a-z0-9\.\+\-\_]*@[a-z0-9]+[a-z\d\-]*(\.[a-z\d\-]+)*\.[a-z]{2,}\z/i.freeze
  validates :address, confirmation: { case_sensitive: false },
                          presence: true,
                            length: { maximum: 255 },
                            format: { with: VALID_EMAIL_FORMAT },
                        uniqueness: { case_sensitive: false }
  validates :address, with: :check_email_address_repetitions
  
  # # UNCOMMENT THE FOLLOWING LINE TO MAKE THE address_confirmation MANDATORY
  # # AND THUS, ALWAYS TRIGGER THE PREVIOUS confirmation: { case_sensitive: false } VALIDATOR ON :address ATTRIBUTE
  # validates :address_confirmation, presence: true
  
  def to_s = address
    
  # def ==(email_address)
  #   return false unless email_address.respond_to?(:address)
  #   self.address.match?(/#{email_address.address}/i)
  # end
    
  private
  
  # # to be invoked in the before_save callback
  def downcase_address = address.downcase!
  
  # provisional until the email activation subsystem get ready
  def activate_email_address
    # self.activation_digest = EmailAddress.digest(address)
    self.activated_at = Time.now
    self.activated = true
  end
  
  # custom validator
  def check_email_address_repetitions
    return if self.nil? || self.address.nil? || self.owner.nil?
    self.owner.email_addresses.each do |email_address|
      next if self.eql?(email_address) 
      if self.address.match?(/#{email_address.address}/i)
        self.errors.add(:address, "is repeated as #{email_address.address}")
        return
      end
    end
  end
end
