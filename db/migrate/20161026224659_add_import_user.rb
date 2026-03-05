class AddImportUser < ActiveRecord::Migration[5.0]
  def up
    User.create!({email: "imports@ebmpros.com", is_active: false,
                  first_name: "Import", last_name: "User",
                  role: "imports", password: "321321321", password_confirmation: "321321321" })
  end
  def down
    User.where(email: "import@ebmpros.com").delete_all
  end
end
