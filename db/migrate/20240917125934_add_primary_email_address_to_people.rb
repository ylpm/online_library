class AddPrimaryEmailAddressToPeople < ActiveRecord::Migration[7.1]
  def change
    add_reference :people, :primary_email_address, null: true, foreign_key: {to_table: :email_addresses}, index: false

    add_index :people, :primary_email_address_id, unique: true
  end
end
