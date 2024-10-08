module Personable
  extend ActiveSupport::Concern

  included do
    has_one :person, as: :personable, touch: true, dependent: :destroy
    
    default_scope -> { includes(:person).order(created_at: :asc) } # por defecto, se hace un eagger loading del person asociado al personable
    
    accepts_nested_attributes_for :person
    
    has_many :email_addresses, through: :person,
                               source: :email_addresses,
                               dependent: :destroy,
                               inverse_of: :owner,
                               foreign_key: :owner_id,
                               validate: true,
                               autosave: true
    
    has_one :primary_email_address, through: :person,
                                    source: :primary_email_address
    
    # delegate *Person.instance_methods(false), to: :person
    # delegate *Person.singleton_methods, to: :class
    
    delegate :first_name, :middle_name, :last_name, :full_name,
             :birthday,
             :gender, :gender?,
             :registered_email_addresses, :activated_email_addresses,
             :primary_image,
             to: :person

  end
  
  class_methods do
  end

end