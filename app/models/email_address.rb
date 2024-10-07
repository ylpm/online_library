class EmailAddress < ApplicationRecord
  belongs_to :owner, class_name: 'Person', inverse_of: :email_addresses, required: true
  
  has_one :owner_marked_as_primary, required: false,
                                    class_name: 'Person',
                                    foreign_key: :primary_email_address_id,
                                    inverse_of: :primary_email_address
  
  has_many :identified_sessions, class_name: 'Session', inverse_of: :email_address_identifier
  
  default_scope -> { includes(:owner).order(created_at: :asc) } # Para mejorar rendimiento,
                                                                # indexar la columna created_at
  scope :activated, -> { where(activated: true) }
  scope :deactivated, -> { where(activated: [false, nil]) }
  
  # scope :primary, -> { ... } # e.g., used to retrieve all primary email addresses as EmailAddress.primary
  
  def primary?
    !owner_marked_as_primary.nil?
  end
      
  before_save do
    self.address.downcase!
    # provisional activation:
    self.activated_at = Time.now
    self.activated = true
  end
                
  VALID_EMAIL_FORMAT = /\A[a-z][a-z0-9\.\+\-\_]*@[a-z0-9]+[a-z\d\-]*(\.[a-z\d\-]+)*\.[a-z]{2,}\z/i.freeze
  validates :address, confirmation: { case_sensitive: false },
                          presence: true,
                            length: { maximum: 255 },
                            format: { with: VALID_EMAIL_FORMAT },
                        uniqueness: { case_sensitive: false },
                            unless: :email_address_repeated?
  
  # # UNCOMMENT THE FOLLOWING LINE TO MAKE THE address_confirmation MANDATORY
  # # AND THUS, ALWAYS TRIGGER THE PREVIOUS confirmation: { case_sensitive: false } VALIDATOR ON :address ATTRIBUTE
  # validates :address_confirmation, presence: true
  
  def to_s = address
    
  # def ==(email_address)
  #   return false unless email_address.respond_to?(:address)
  #   self.address.match?(/\A#{email_address.address}\z/i)
  # end
    
  private
  
  # Custom validator
  def email_address_repeated?
    unless self.address.nil? || self.owner.nil?
      self.owner.email_addresses.each do |email_address|
        next if self.eql?(email_address)
        if self.address.match?(/\A#{email_address.address}\z/i)
          self.errors.add(:address, "you are repeating this email address")
          return true
        end
      end
    end
    false
  end
end
