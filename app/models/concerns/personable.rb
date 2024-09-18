module Personable
  extend ActiveSupport::Concern

  included do
    has_one :person, as: :personable, touch: true, dependent: :destroy
    
    accepts_nested_attributes_for :person
    
    # delegate *Person.instance_methods(false), to: :person
    # delegate *Person.singleton_methods, to: :class
    
    delegate :first_name, :middle_name, :last_name, :full_name,
             :birthday,
             :gender, :gender?,
             :email_addresses, :primary_email_address,
             :primary_image,
             to: :person
  end
  
  class_methods do
  end

end