class AddGenderToPeople < ActiveRecord::Migration[7.1]
  def change
    add_column :people, :gender, :string, default: "Not Specified", null: false
  end
end
