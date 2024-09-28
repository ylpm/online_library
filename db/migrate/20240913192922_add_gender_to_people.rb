class AddGenderToPeople < ActiveRecord::Migration[7.1]
  def change
    add_column :people, :gender, :string
  end
end
