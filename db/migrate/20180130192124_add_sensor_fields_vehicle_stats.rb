class AddSensorFieldsVehicleStats < ActiveRecord::Migration[5.0]
  def change
    add_column :vehicle_stats, :co, :decimal, precision: 12, scale: 4
    add_column :vehicle_stats, :hydrocarbons, :decimal, precision: 12, scale: 4
    add_column :vehicle_stats, :heater_voltage, :decimal, precision: 12, scale: 4
    add_column :vehicle_stats, :heater_current, :decimal, precision: 12, scale: 4
    add_column :vehicle_stats, :fuel_level_percent, :decimal, precision: 12, scale: 4
    add_column :vehicle_stats, :fuel_gallons, :decimal, precision: 12, scale: 4
    add_column :vehicle_stats, :truck_payload_tons, :decimal, precision: 12, scale: 4
    add_column :vehicle_stats, :truck_miles_traveled, :decimal, precision: 12, scale: 4
    rename_column :vehicle_stats, :sensor_oil_temperature, :oil_temperature
  end
end
