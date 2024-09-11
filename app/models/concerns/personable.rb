module Personable
  extend ActiveSupport::Concern

  included do
    has_one :person, as: :personable, touch: true, dependent: :destroy
    accepts_nested_attributes_for :person
  end
  
  class_methods do
  end
  
  def first_name = self.person.first_name
  
  def middle_name = self.person.middle_name
  
  def last_name = self.person.last_name
    
  def full_name = self.person.full_name
  
  def birthday = self.person.birthday
  
  def email_addresses = self.person.email_addresses
end