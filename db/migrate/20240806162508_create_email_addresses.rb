class CreateEmailAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :email_addresses do |t|
      t.string :address, null: false
      t.belongs_to :person, null: false, foreign_key: true

      t.timestamps
    end
  end
end
