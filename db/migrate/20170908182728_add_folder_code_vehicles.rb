class AddFolderCodeVehicles < ActiveRecord::Migration[5.0]
  def change
    add_column :vehicles, :folder_code, :string
  end
end
