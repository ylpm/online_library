class Session < ApplicationRecord
  belongs_to :user
  
  belongs_to :email_address, required: false, inverse_of: :sessions
  
  def login_identifier
    (email_address.address if email_address) || user.username
  end
end
