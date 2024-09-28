module PeopleHelper
  def gender_options_for(person, include_blank: true)
    return unless person.respond_to?(:gender)
    options_for_select(attribute_options(Person::GENDERS.map{|gender| [gender, gender]}, include_blank: include_blank),
                       person.gender)
  end
  
  def primary_email_address_options_for(person, include_blank: true)
    return unless person.respond_to?(:activated_email_addresses) && person.respond_to?(:primary_email_address)
    options_for_select(attribute_options(person.activated_email_addresses.map {|e| [e.address, e.id]}, include_blank: include_blank), 
                       person.primary_email_address.id)
  end
  
  private
  
  def attribute_options(pemitted_options, include_blank: true)
    options = []
    options << nil_option if include_blank
    options += pemitted_options
  end
  
  def nil_option = ["Not Specified", nil]
end
