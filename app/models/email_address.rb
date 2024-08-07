class EmailAddress < ApplicationRecord
  belongs_to :person
  
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
  
  VALID_EMAIL_FORMAT = /\A[a-z][a-z0-9\.\+\-\_]*@[a-z0-9]+[a-z\d\-]*(\.[a-z\d\-]+)*\.[a-z]{2,}\z/i.freeze
  validates :address, presence: true,
                        length: {maximum: 255},
                        format: {with: VALID_EMAIL_FORMAT},
                        uniqueness: true # { case_sensitive: false }
  
  validates :person_id, presence: true
  
  def to_s = address
    
  private
  
  # # to be invoked in the before_save callback
  def downcase_address = address.downcase!
end
