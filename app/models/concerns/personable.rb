module Personable
  extend ActiveSupport::Concern

  included do
    has_one :person, as: :personable, touch: true
  end
  
  # ESTO QUE SIGUE FUNCIONA PERO EL PROBLEMA ESTA CUANDO SE LLAMAN LOS METODOS DE ACTIVE RECORD COMO update
  # update_attribute:
  # def first_name
  #   self.person.first_name
  # end
  #
  # def first_name=(first_name)
  #   self.person.first_name = first_name
  # end
end