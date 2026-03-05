class AddFilenameVehicleStats < ActiveRecord::Migration[5.0]
  def change
    add_column :vehicle_stats, :filename, :string
    add_index :vehicle_stats, :filename
  end
end
