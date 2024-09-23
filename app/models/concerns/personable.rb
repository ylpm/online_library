module Personable
  extend ActiveSupport::Concern

  included do
    has_one :person, as: :personable, touch: true, dependent: :destroy
    
    default_scope -> { includes(:person).order(created_at: :asc) } # por defecto, se hace un eagger loading del person asociado
    
    accepts_nested_attributes_for :person
    
    has_many :email_addresses, through: :person,
                               source: :email_addresses,
                               dependent: :destroy,
                               inverse_of: :owner,
                               foreign_key: :owner_id,
                               validate: true,
                               autosave: true
    
    # delegate *Person.instance_methods(false), to: :person
    # delegate *Person.singleton_methods, to: :class
    
    delegate :first_name, :middle_name, :last_name, :full_name,
             :birthday,
             :gender, :gender?,  # :email_addresses, 
             :primary_email_address,
             :primary_image,
             to: :person

  end
  
  class_methods do
  end

end