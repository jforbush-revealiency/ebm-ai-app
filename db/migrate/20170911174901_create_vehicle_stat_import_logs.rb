class CreateVehicleStatImportLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :vehicle_stat_import_logs do |t|
      t.string :code
      t.string :filename
      t.string :status
      t.string :log, limit: 4000 

      t.timestamps
    end
  end
end
