class VehicleStats < ActiveRecord::Migration[5.0]
  def change
    create_table :vehicle_stats do |t|
      t.string :code
      t.datetime :datetime
      t.integer :percent_load
      t.integer :rpm
      t.integer :coolant_temperature
      t.integer :right_exhaust_temperature
      t.integer :left_exhaust_temperature
      t.integer :ecm_oil_temperature
      t.integer :warning_status
      t.integer :shutdown_status
      t.integer :derate_warning
      t.integer :warning_2
      t.integer :shutdown_2
      t.decimal :throttle_position, precision: 12, scale: 4
      t.decimal :system_voltage, precision: 12, scale: 4
      t.decimal :atmospheric_pressure, precision: 12, scale: 4
      t.decimal :oil_pressure_psi, precision: 12, scale: 4
      t.decimal :boost_psi, precision: 12, scale: 4
      t.decimal :boost_abs_psi, precision: 12, scale: 4
      t.decimal :intake_air_temperature, precision: 12, scale: 4
      t.decimal :fuel_temperature, precision: 12, scale: 4
      t.decimal :lifetime_fuel_consumption, precision: 12, scale: 4
      t.decimal :lifetime_operating_hours, precision: 12, scale: 4
      t.decimal :duty_cycle_t1, precision: 12, scale: 4
      t.decimal :duty_cycle_t2, precision: 12, scale: 4
      t.decimal :duty_cycle_t3, precision: 12, scale: 4
      t.decimal :lifetime_idle_hours, precision: 12, scale: 4
      t.decimal :lifetime_idle_fuel, precision: 12, scale: 4
      t.decimal :nox_ppm, precision: 12, scale: 4
      t.decimal :o2_percent, precision: 12, scale: 4
      t.decimal :colima_1, precision: 12, scale: 4
      t.decimal :colima_2, precision: 12, scale: 4
      t.decimal :sensor_oil_temperature, precision: 12, scale: 4
      t.decimal :ambient_temperature, precision: 12, scale: 4
      t.decimal :oil_condition, precision: 12, scale: 4

      t.string :fault_high_exhaust_temperature_warning, limit: 3
      t.string :fault_engine_overspeed_warning, limit: 3
      t.string :fault_low_coolant_temperature_warning, limit: 3
      t.string :fault_high_coolant_temperature_warning, limit: 3
      t.string :fault_low_engine_oil_pressure_warning, limit: 3
      t.string :fault_low_system_volts_warning, limit: 3
      t.string :fault_high_air_temperature_warning, limit: 3
      t.string :fault_high_oil_temperature_warning, limit: 3
      t.string :fault_high_hydraulic_oil_temperature_warning, limit: 3
      t.string :fault_no_coolant_flow_warning, limit: 3
      t.string :fault_high_after_coolant_temperature_warning, limit: 3
      t.string :fault_high_crankcase_pressure_warning, limit: 3
      t.string :fault_fuel_filer_plugged_warning, limit: 3
      t.string :fault_oil_filer_plugged_warning, limit: 3
      t.string :fault_low_coolant_level_warning, limit: 3
      t.string :fault_alternator_not_charging_warning, limit: 3
      t.string :fault_low_fuel_level_warning, limit: 3
      t.string :fault_low_fuel_pressure_warning, limit: 3
      t.string :fault_high_fuel_temperature_warning, limit: 3
      t.string :fault_low_intake_manifold_pressure_warning, limit: 3
      t.string :fault_high_intake_manifold_pressure_warning, limit: 3
      t.string :fault_low_oil_level_warning, limit: 3
      t.string :fault_engine_oil_bypass_warning, limit: 3
      t.string :fault_high_exhaust_temperature_shutdown, limit: 3
      t.string :fault_air_filter_plugged_shutdown, limit: 3
      t.string :fault_engine_overspeed_shutdown, limit: 3
      t.string :fault_low_engine_coolant_temperature_shutdown, limit: 3
      t.string :fault_high_engine_coolant_temperature_shutdown, limit: 3
      t.string :fault_low_engine_oil_pressure_shutdown, limit: 3
      t.string :fault_low_system_volts_shutdown, limit: 3
      t.string :fault_high_engine_airintake_temperature_shutdown, limit: 3
      t.string :fault_high_engine_oil_temperature_shutdown, limit: 3
      t.string :fault_high_crankcase_pressure_shutdown, limit: 3
      t.string :fault_fuel_filter_plugged_shutdown, limit: 3
      t.string :fault_oil_filter_plugged_shutdown, limit: 3
      t.string :fault_low_coolant_level_shutdown, limit: 3
      t.string :fault_alternator_not_charging_shutdown, limit: 3
      t.string :fault_low_fuel_level_shutdown, limit: 3
      t.string :fault_low_fuel_pressure_shutdown, limit: 3
      t.string :fault_high_fuel_temperature_shutdown, limit: 3
      t.string :fault_low_intake_manifold_pressure_shutdown, limit: 3
      t.string :fault_high_intake_manifold_pressure_shutdown, limit: 3
      t.string :fault_low_oil_level_shutdown, limit: 3
      t.string :fault_engine_oil_filter_bypass_shutdown, limit: 3
      t.string :fault_high_exhaust_temperature_derate, limit: 3
      t.string :fault_air_filter_plugged_derate, limit: 3
      t.string :fault_engine_overspeed_derate, limit: 3
      t.string :fault_low_engine_coolant_temperature_derate, limit: 3
      t.string :fault_high_engine_coolant_temperature_derate, limit: 3
      t.string :fault_low_engine_oil_pressure_derate, limit: 3
      t.string :fault_low_system_voltage_derate, limit: 3
      t.string :fault_high_engine_air_temperature_derate, limit: 3
      t.string :fault_high_engine_oil_temperature_derate, limit: 3
      t.string :fault_high_hydraulic_oil_temperature_derate, limit: 3
      t.string :fault_no_coolant_flow_derate, limit: 3
      t.string :fault_high_after_coolant_temperature_derate, limit: 3
      t.string :fault_high_crankcase_pressure_derate, limit: 3
      t.string :fault_fuel_filter_plugged_derate, limit: 3
      t.string :fault_oil_filter_plugged_derate, limit: 3
      t.string :fault_low_coolant_level_derate, limit: 3
      t.string :fault_alternator_not_charging_derate, limit: 3
      t.string :fault_low_fuel_level_derate, limit: 3
      t.string :fault_low_fuel_pressure_derate, limit: 3
      t.string :fault_high_fuel_temperature_derate, limit: 3
      t.string :fault_low_intake_manifold_pressure_derate, limit: 3
      t.string :fault_high_intake_manifold_pressure_derate, limit: 3
      t.string :fault_low_oil_level_shutdown_derate, limit: 3
      t.string :fault_engine_oil_filter_bypass_derate, limit: 3
      t.string :fault_high_engine_vibration_derate, limit: 3
      t.string :fault_low_oil_filter_pressure_derate, limit: 3
      t.string :fault_high_oil_filter_pressure_derate, limit: 3
      t.string :fault_high_engine_oil_pressure_derate, limit: 3
      t.string :fault_low_coolant_to_engine_oil_temperature_difference_derate, limit: 3
      t.string :fault_low_coolant_pressure_derate, limit: 3
      t.string :fault_low_coolant_level_derate, limit: 3
      t.string :fault_high_coolant_temperature_derate, limit: 3
      t.string :fault_low_exhaust_temperature_deviation_derate, limit: 3
      t.string :fault_high_exhaust_temperature_deviation_derate, limit: 3
      t.string :fault_high_exhaust_temperature_difference_derate, limit: 3
      t.string :fault_high_intake_manifold_air_temperature_derate, limit: 3
      t.string :fault_high_crankcase_metal_particulate_derate, limit: 3
      t.string :fault_high_pressure_oilline_broken_derate, limit: 3
      t.string :fault_high_injector_actuation_pressure_derate, limit: 3
      t.string :fault_high_fuel_cool_seperator_water_level_derate, limit: 3
      t.string :fault_high_fuel_rail_pump_flow_derate, limit: 3
      t.string :fault_low_inlet_air_temperature_derate, limit: 3
      t.string :fault_high_fuel_pressure_line_broken_derate, limit: 3
      t.string :fault_global_active_derate, limit: 3

      t.timestamps
    end

    add_index :vehicle_stats, :code
    add_index :vehicle_stats, :datetime
  end
end
