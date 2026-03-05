class AddAdminUser < ActiveRecord::Migration[5.0]
  def up
    User.create!({email: "j4bushcpa@gmail.com", 
                  first_name: "Jeramiah", last_name: "Forbush",
                  role: "site_admin", password: "11111111", password_confirmation: "11111111" })
  end
  def down
    User.delete_all
  end
end
