class CreatePeople < ActiveRecord::Migration[7.1]
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :middle_name, null: true
      t.string :last_name
      # t.boolean :sex, null: true
      t.date :birthday, null: true

      t.timestamps
    end
  end
end
