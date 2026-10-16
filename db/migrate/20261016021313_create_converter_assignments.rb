class CreateConverterAssignments < ActiveRecord::Migration[7.2]
  def change
    create_table :converter_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :converter, null: false, foreign_key: true

      t.timestamps
    end


    add_index :converter_assignments, [:user_id, :converter_id], unique: true
  end
end
