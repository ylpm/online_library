class AddSessionDigestToSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :sessions, :session_digest, :string
  end
end