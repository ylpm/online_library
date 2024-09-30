module PersonableHandler
  extend ActiveSupport::Concern
  
  included do
    #...
  end
  
  class_methods do
    #...
  end
  
  def new_personable(klass)
    check_personable_class(klass)

    personable = klass.new(person: Person.new)
    
    # personable.person.email_addresses.build if klass.equal?(User) # when a new personable is created and it is a User
                                                                  # it is mandatory to associate an email address with him
                                                                  # but it is better to do this in the users controller

    return personable unless block_given?

    yield personable
  end
  
  def create_personable(klass, personable_params)
    check_personable_class(klass)

    personable = klass.create(personable_params)
    
    if personable.persisted? && personable.person.email_addresses.any?
      personable.primary_email_address = personable.email_addresses.first
      personable.save
      # personable.person.update_column(:primary_email_address_id, personable.email_addresses.first.id)
    end
    
    return personable unless block_given?

    yield personable
  end

  def update_personable(personable, personable_params)
    check_personable(personable)
 
    updated = personable.update(personable_params)
    
    # debugger # !!!!!!!!!!!!!!!!
    
    return updated unless block_given?
    
    yield updated
  end
  
  def destroy_personable(personable)
    check_personable(personable)
    personable.destroy if personable.persisted?
    yield if block_given?
  end

  private
  
  def check_personable_class(personable_class)
    raise ArgumentError, "#{personable_class} (instance of #{personable_class.class}) is not a Prsonable" unless personable_class.is_a?(Class) && personable_class.include?(Personable)
  end
  
  def check_personable(personable)
    raise ArgumentError, "#{personable} (instance of #{personable.class}) is not a Personable" unless personable.class.include?(Personable)
  end
  
end