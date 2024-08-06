class Person < ApplicationRecord
  
  VALID_FIRST_NAME_FORMAT = /\A[a-zA-Z]{3,50}\Z/i.freeze
  validates :first_name, presence: true,
                           # length: {minimum: 3, maximum: 50},
                           format: {with: VALID_FIRST_NAME_FORMAT}
                          
  VALID_MIDDLE_NAME_FORMAT = /\A([a-z\d]+(\s[a-z\d]+)*)*\Z/i.freeze
  validates :middle_name, presence: false,
                            length: {maximum: 50},
                            format: {with: VALID_MIDDLE_NAME_FORMAT}
  
  VALID_LAST_NAME_FORMAT = /\A[a-z\d]+(\s[a-z\d]+)*\Z/i.freeze
  validates :last_name, presence: true,
                          length: {maximum: 50},
                          format: {with: VALID_LAST_NAME_FORMAT}
  
  validates :sex, presence: false
  
  # VALID_BIRTHDAY_FORMAT = /\A[\d]{4}-[\d]{2}-[\d]{2}\Z/i.freeze
  validates :birthday, presence: false
                       # format: {with: VALID_BIRTHDAY_FORMAT}
                       
  def sex
    return 'male' if self.sex == 0
    return 'female' if self.sex == 1
    nil
  end
end
