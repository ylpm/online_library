module PersonableHandler
  extend ActiveSupport::Concern
  
  included do
    #...
  end
  
  class_methods do
    #...
  end
  
  def new_personable(personable_class)
    check_personable_class(personable_class)
    personable = personable_class.new(person: Person.new)
    email_address = personable.person.email_addresses.new
    yield(personable, email_address) if block_given?
  end
  
  def create_personable(personable_class, personable_params)
    check_personable_class(personable_class)
    
    valid = (personable = personable_class.new personable_params).valid?

    valid &= (personable.person = Person.new first_name: person_params[:first_name],
                                            middle_name: person_params[:middle_name],
                                              last_name: person_params[:last_name],
                                               birthday: person_params[:birthday],
                                             personable: personable).valid?
    
    valid &= personable.person.email_addresses.new(address: person_params[:email_address][:address]).valid?
    
    if valid
      personable.save
      personable.person.save
      personable.person.email_addresses.first.save
    end

    yield personable
  end

  def update_personable(personable, personable_params)
    check_personable(personable)
 
    updated = personable.update(personable_params)

    updated &= personable.person.update(first_name: person_params[:first_name],
                                       middle_name: person_params[:middle_name],
                                         last_name: person_params[:last_name],
                                          birthday: person_params[:birthday])
    
    yield(personable, updated)
  end
  
  def destroy_personable(personable)
    check_personable(personable)
    personable.destroy if personable.persisted?
    yield personable if block_given?
  end

  private
  
  def check_personable_class(personable_class)
    raise ArgumentError, "#{personable_class} (instance of #{personable_class.class}) is not a personable" unless personable_class.is_a?(Class) && personable_class.include?(Personable)
  end
  
  def check_personable(personable)
    raise ArgumentError, "#{personable} (instance of #{personable.class}) is not a personable" unless personable.class.include?(Personable)
  end
  
end