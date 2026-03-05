class AddImportUser < ActiveRecord::Migration[7.1]
  def up
    return if User.exists?(email: "imports@ebmpros.com")
    u = User.new(email: "imports@ebmpros.com", is_active: false,
                 first_name: "Import", last_name: "User",
                 role: "imports", password: "changeme123", password_confirmation: "changeme123")
    u.save(validate: false)
  end
  def down
    User.where(email: "imports@ebmpros.com").delete_all
  end
end
