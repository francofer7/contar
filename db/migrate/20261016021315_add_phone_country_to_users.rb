class AddPhoneCountryToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :phone_country, :string, null: false, default: "AR"
  end
end
