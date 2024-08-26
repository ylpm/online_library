class AddEmailToSessions < ActiveRecord::Migration[7.1]
  def change
    add_reference :sessions, :email_address, null: true, foreign_key: true
  end
end
