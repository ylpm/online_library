class User < ApplicationRecord
  include Personable
  
  has_secure_password # requires a password_digest field at database level users table and the bcrypt gem
                      # adds two virtual attributes to User model: password and password_digest
  
  before_save :downcase_username
  
  VALID_USERNAME_REGEXP = /\A[a-z]([\-\_\.]?[a-z\d]+)+\Z/i.freeze
  validates :username, presence: true,
                         length: { minimum: 3, maximum: 30 }, # se puede incluir en el formato, y se quita de aqui
                         format: { with: VALID_USERNAME_REGEXP },
                         uniqueness: true # { case_sensitive: false } esto no es necesario cuando se añade el callback downcase_username
                         
  VALID_PASSWORD_REGEXP = /\A(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[\W]).{8,}$\z/
  validates :password, presence: true,
                         length: { minimum: 8 }, # maximum: 50 }
                         format: { with: VALID_PASSWORD_REGEXP }  

  def User.custom_create(attrs = {})
    # return nil if !attrs[:first_name] || !attrs[:last_name] || !attrs[:username]

    person = Person.create first_name: attrs[:first_name],
                            last_name: attrs[:last_name],
                           personable: User.new(username: attrs[:username],
                                                password: attrs[:password],
                                                password_confirmation: attrs[:password_confirmation])

    person.update_attribute(:middle_name, attrs[:middle_name]) if attrs[:middle_name]
    person.update_attribute(:birthday, attrs[:birthday]) if attrs[:birthday]

    if email = attrs[:email]
      if email.respond_to? :each
        email.each do |address|
          person.email_addresses.create(address: address)
        end
      else
        person.email_addresses.create(address: email)
      end
    end

    person.user
  end

  def to_s = "#{self.person.first_name} #{self.person.last_name} <#{self.username}>"


  private
  
  def downcase_username = self.username.downcase!
    
end
