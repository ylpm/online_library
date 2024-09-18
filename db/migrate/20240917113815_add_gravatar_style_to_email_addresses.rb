class AddGravatarStyleToEmailAddresses < ActiveRecord::Migration[7.1]
  def change
    add_column :email_addresses, :gravatar_style, :string
  end
end
