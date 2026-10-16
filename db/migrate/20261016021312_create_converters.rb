class CreateConverters < ActiveRecord::Migration[7.2]
  def change
    create_table :converters do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description, null: false
      t.string :source_file, null: false
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end


    add_index :converters, :key, unique: true
  end
end
