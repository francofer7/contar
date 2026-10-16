class AddPhoneToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :phone, :string, null: false, default: ""
    change_column_default :users, :phone, from: "", to: nil
  end
end
