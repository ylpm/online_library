class User < ApplicationRecord
  include Personable
  
  before_save :downcase_username
  
  VALID_USERNAME_FORMAT = /\A[a-z]([\-\_\.]?[a-z\d]+)+\Z/i.freeze
  validates :username, presence: true,
                         length: { minimum: 3, maximum: 30 }, # se puede incluir en el formato, y se quita de aqui
                         format: { with: VALID_USERNAME_FORMAT },
                         uniqueness: true # { case_sensitive: false } esto no es necesario cuando se añade el callback downcase_username

  def User.custom_create(attrs = {})
    # return nil if !attrs[:first_name] || !attrs[:last_name] || !attrs[:username]

    person = Person.create first_name: attrs[:first_name],
                            last_name: attrs[:last_name],
                           personable: User.new(username: attrs[:username])

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
