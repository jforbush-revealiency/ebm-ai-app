class RenameOilTemperatureVehicleStatusView < ActiveRecord::Migration[7.1]
  def up
    connection.execute "DROP VIEW IF EXISTS vehicle_stats_by_day;"
    connection.execute "DROP VIEW IF EXISTS vehicle_stats_by_day_percent_load;"

    connection.execute %Q( CREATE OR REPLACE VIEW vehicle_stats_by_day_percent_load AS
      SELECT date,
        avg(system_voltage) as system_voltage_average_with_load,
        avg(boost_psi) as boost_psi_average_with_load,
        avg(oil_temperature) oil_temperature_with_load
      FROM vehicle_stats
      WHERE rpm > 0 and percent_load > 90
      GROUP BY date ORDER BY date; )

    connection.execute %Q( CREATE OR REPLACE VIEW vehicle_stats_by_day AS
      SELECT rpm_0.date, percent_load_average, rpm_average,
        coolant_temperature_average, coolant_temperature_maximum,
        right_exhaust_temperature_average, left_exhaust_temperature_average,
        nox_ppm_average, o2_percent_average, fuel_gallons_per_hour_average,
        rpm_count_less_than_equal_to_900, rpm_average_less_than_equal_to_900,
        oil_pressure_psi_average_less_than_equal_to_900,
        oil_pressure_psi_average_greater_than_equal_to_1600,
        last_lifetime_operating_hours, last_lifetime_idle_hours,
        last_id, last_oil_condition_id,
        vs1.oil_condition as last_oil_condition,
        system_voltage_average_with_load, boost_psi_average_with_load,
        oil_temperature_with_load
      FROM vehicle_stats_by_day_rpm_0 rpm_0
        LEFT OUTER JOIN vehicle_stats_by_day_rpm_900 rpm_900 ON (rpm_0.date = rpm_900.date)
        LEFT OUTER JOIN vehicle_stats_by_day_rpm_1600 rpm_1600 ON (rpm_0.date = rpm_1600.date)
        LEFT OUTER JOIN vehicle_stats_by_day_no_rpm no_rpm ON (rpm_0.date = no_rpm.date)
        LEFT OUTER JOIN vehicle_stats_by_day_percent_load percent_load ON (rpm_0.date = percent_load.date)
        LEFT OUTER JOIN vehicle_stats_by_day_oil_condition oc ON (rpm_0.date = oc.date)
        LEFT OUTER JOIN vehicle_stats vs1 ON (vs1.id = oc.last_oil_condition_id)
      ORDER BY rpm_0.date; )
  end

  def down
    connection.execute "DROP VIEW IF EXISTS vehicle_stats_by_day;"
    connection.execute "DROP VIEW IF EXISTS vehicle_stats_by_day_percent_load;"
  end
end