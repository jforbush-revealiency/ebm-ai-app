class AddFieldsV2VehicleStats < ActiveRecord::Migration[5.0]
  def change
    add_column :vehicle_stats, :filter_oil_pressure, :decimal, precision: 12, scale: 4
    add_column :vehicle_stats, :smoke_setting, :decimal, precision: 12, scale: 4
    add_column :vehicle_stats, :fuel_gallons_per_hour, :decimal, precision: 12, scale: 4
    add_column :vehicle_stats, :fuel_rate, :decimal, precision: 12, scale: 4
    add_column :vehicle_stats, :is_cdl_online, :string, limit: 3
    add_column :vehicle_stats, :nox_signal_status, :integer
    add_column :vehicle_stats, :o2_signal_status, :integer
    add_column :vehicle_stats, :nox_not_valid, :string, limit: 3
    add_column :vehicle_stats, :nox_valid, :string, limit: 3
    add_column :vehicle_stats, :nox_error, :string, limit: 3
    add_column :vehicle_stats, :nox_na, :string, limit: 3
    add_column :vehicle_stats, :nox_fmi_shorted, :string, limit: 3
    add_column :vehicle_stats, :nox_fmi_openwire, :string, limit: 3
    add_column :vehicle_stats, :o2_not_valid, :string, limit: 3
    add_column :vehicle_stats, :o2_valid, :string, limit: 3
    add_column :vehicle_stats, :o2_error, :string, limit: 3
    add_column :vehicle_stats, :o2_na, :string, limit: 3
    add_column :vehicle_stats, :o2_fmi_shorted, :string, limit: 3
    add_column :vehicle_stats, :o2_fmi_openwire, :string, limit: 3
  end
end
