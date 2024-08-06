class AddIndexToEmailAddressesAddress < ActiveRecord::Migration[7.1]
  def change
    add_index :email_addresses, :address, unique: true
  end
end
