class AddAdminUser < ActiveRecord::Migration[7.1]
  def up
    return if User.exists?(role: "site_admin")
    u = User.new(email: "admin@ebmpros.com", first_name: "Admin",
                 last_name: "User", role: "site_admin",
                 password: "changeme123", password_confirmation: "changeme123")
    u.save(validate: false)
  end
  def down
    User.where(role: "site_admin").delete_all
  end
end
