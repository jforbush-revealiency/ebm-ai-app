class AddDateTimeFieldsVehicleStats < ActiveRecord::Migration[5.0]
  def change
    add_column :vehicle_stats, :date, :date
    add_column :vehicle_stats, :time, :time
  end
end
