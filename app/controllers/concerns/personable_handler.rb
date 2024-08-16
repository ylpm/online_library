module PersonableHandler
  extend ActiveSupport::Concern
  
  included do
    #...
  end
  
  class_methods do
    #...
  end
  
  def create_personable personable_class, personable_params
    raise ArgumentError, "#{personable_class} (instance of #{personable_class.class}) is not a personable" unless personable_class.is_a?(Class) && personable_class.include?(Personable)
        
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
  
end