class AddSubclassFieldsToPeople < ActiveRecord::Migration[7.1]
  def change
    add_column :people, :personable_type, :string, null: false
    add_column :people, :personable_id, :integer, null: false
    # add_reference :people, :personable_id, null: false, foreign_key: { to_table: :users }
    add_index :people, [:personable_type, :personable_id], unique: true
  end
end
