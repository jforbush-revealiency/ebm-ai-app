class AddEngineConfigTelematics < ActiveRecord::Migration[5.0]
  def change
    add_column :engine_configs, :co2_plus_o2_percent, :decimal, precision: 12, scale: 4
    add_column :engine_configs, :test_percent_load, :decimal, precision: 12, scale: 4
    add_column :engine_configs, :test_rpm, :decimal, precision: 12, scale: 4
    add_column :engine_configs, :test_boost_psi, :decimal, precision: 12, scale: 4
    add_column :engine_configs, :test_fuel_gallons_per_hour, :decimal, precision: 12, scale: 4
  end
end
