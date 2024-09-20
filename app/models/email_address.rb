class EmailAddress < ApplicationRecord
  belongs_to :owner, class_name: 'Person'
  
  has_one :mark_as_primary_for, class_name: 'Person', foreign_key: :primary_email_address_id, inverse_of: :primary_email_address
  
  has_many :sessions, inverse_of: :email_address
  
  default_scope { order(created_at: :asc) } # para mejorar rendimiento, indexar la columna created_at
  
  def primary?
    !mark_as_primary_for.nil?
  end
      
	# ## CALLBACKS:
	# ### Hay dos formas de usar los callbacks:
	# ### 	1. pasandoles un bloque
	# ### 	2. referenciando un metodo 

	# ### ejemplo de callback pasandole un bloque
	# before_save do 
	# 	address.downcase!
	# end
	# ### ejemplo de callback referenciando un metodo
  before_save :downcase_address
  before_save :activate_email_address # provisional
  
  VALID_EMAIL_FORMAT = /\A[a-z][a-z0-9\.\+\-\_]*@[a-z0-9]+[a-z\d\-]*(\.[a-z\d\-]+)*\.[a-z]{2,}\z/i.freeze
  validates :address, presence: true,
                        length: {maximum: 255},
                        format: {with: VALID_EMAIL_FORMAT},
                    uniqueness: { case_sensitive: false } # scope: :owner_id
  
  validates :address, with: :unique_for_its_owner
  
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
  
  def unique_for_its_owner
    return if self.nil? || self.address.nil? || self.owner.nil?
    self.owner.email_addresses.each_with_index do |email_address, index|
      next if self.eql?(email_address) 
      if self.address.match?(/#{email_address.address}/i)
        self.errors.add(:address, "is repeated as #{email_address.address}")
        return
      end
    end
  end
end
