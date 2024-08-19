class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :sessions, [:user_id, :created_at], unique: true
  end
end
