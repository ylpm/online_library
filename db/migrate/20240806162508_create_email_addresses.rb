class CreateEmailAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :email_addresses do |t|
      t.string :address, null: false
      t.belongs_to :owner, null: false, foreign_key: {to_table: :people}

      t.timestamps
    end
  end
end
