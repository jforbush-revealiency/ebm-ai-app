class CreateVehicleStatsViews < ActiveRecord::Migration[5.0]
  def up
    add_index :vehicle_stats, :date
    add_index :vehicle_stats, :time

    self.connection.execute %Q( CREATE OR REPLACE VIEW vehicle_stats_by_day_rpm_0 AS
          SELECT
              date,
              AVG(percent_load) as percent_load_average,
              AVG(rpm) as rpm_average,
              AVG(coolant_temperature) as coolant_temperature_average,
              MAX(coolant_temperature) as coolant_temperature_maximum,
              AVG(right_exhaust_temperature) as right_exhaust_temperature_average,
              AVG(left_exhaust_temperature) as left_exhaust_temperature_average,
              AVG(nox_ppm) as nox_ppm_average,
              AVG(o2_percent) as o2_percent_average,
              AVG(fuel_gallons_per_hour) as fuel_gallons_per_hour_average
            FROM  vehicle_stats
            WHERE rpm > 0
            GROUP BY date 
            ORDER BY date;
          )  
    self.connection.execute %Q( CREATE OR REPLACE VIEW vehicle_stats_by_day_rpm_900 AS
          SELECT
              date,
              count(rpm) as rpm_count_less_than_equal_to_900,
              avg(rpm) as rpm_average_less_than_equal_to_900,
              avg(oil_pressure_psi)  as oil_pressure_psi_average_less_than_equal_to_900
            FROM  vehicle_stats
            WHERE rpm > 0 and rpm <= 900
            GROUP BY date 
            ORDER BY date;
          )  

    self.connection.execute %Q( CREATE OR REPLACE VIEW vehicle_stats_by_day_rpm_1600 AS
          SELECT
              date,
              avg(oil_pressure_psi)  as oil_pressure_psi_average_greater_than_equal_to_1600
            FROM  vehicle_stats
            WHERE rpm >=  1600
            GROUP BY date 
            ORDER BY date;
          )  

    self.connection.execute %Q( CREATE OR REPLACE VIEW vehicle_stats_by_day_no_rpm AS
          SELECT
              date,
              max(lifetime_operating_hours) as last_lifetime_operating_hours,
              max(lifetime_idle_hours) as last_lifetime_idle_hours,
              max(id) as last_id
            FROM  vehicle_stats
            GROUP BY date 
            ORDER BY date;
          )  

    self.connection.execute %Q( CREATE OR REPLACE VIEW vehicle_stats_by_day_oil_condition AS
          SELECT
              date,
              max(id) as last_oil_condition_id
            FROM  vehicle_stats
            WHERE oil_condition is not null
            GROUP BY date 
            ORDER BY date;
          )  

    self.connection.execute %Q( CREATE OR REPLACE VIEW vehicle_stats_by_day_percent_load AS
          SELECT
              date,
              avg(system_voltage) as system_voltage_average_with_load,
              avg(boost_psi) as boost_psi_average_with_load,
              avg(sensor_oil_temperature) sensor_oil_temperature_with_load
            FROM  vehicle_stats
            WHERE rpm > 0 and percent_load > 90
            GROUP BY date 
            ORDER BY date;
          )  

    self.connection.execute %Q( CREATE OR REPLACE VIEW vehicle_stats_by_day AS
          SELECT
             rpm_0.date,
             percent_load_average,
             rpm_average,
             coolant_temperature_average,
             coolant_temperature_maximum,
             right_exhaust_temperature_average,
             left_exhaust_temperature_average,
             nox_ppm_average,
             o2_percent_average,
             fuel_gallons_per_hour_average,
             rpm_count_less_than_equal_to_900,
             rpm_average_less_than_equal_to_900,
             oil_pressure_psi_average_less_than_equal_to_900,
             oil_pressure_psi_average_greater_than_equal_to_1600,
             last_lifetime_operating_hours,
             last_lifetime_idle_hours,
             last_id,
             last_oil_condition_id,
             vs1.oil_condition as last_oil_condition,
             system_voltage_average_with_load,
             boost_psi_average_with_load,
             sensor_oil_temperature_with_load
            FROM vehicle_stats_by_day_rpm_0 rpm_0 
                 LEFT OUTER JOIN vehicle_stats_by_day_rpm_900 rpm_900 ON (rpm_0.date = rpm_900.date)
                 LEFT OUTER JOIN vehicle_stats_by_day_rpm_1600 rpm_1600 ON (rpm_0.date = rpm_1600.date)
                 LEFT OUTER JOIN vehicle_stats_by_day_no_rpm no_rpm ON (rpm_0.date = no_rpm.date)
                 LEFT OUTER JOIN vehicle_stats_by_day_percent_load percent_load ON (rpm_0.date = percent_load.date)
                 LEFT OUTER JOIN vehicle_stats_by_day_oil_condition oc ON (rpm_0.date = oc.date)
                 LEFT OUTER JOIN vehicle_stats vs1 ON (vs1.id = oc.last_oil_condition_id)
            ORDER BY rpm_0.date;
          )  
  end
  def down
    self.connection.execute "DROP VIEW IF EXISTS vehicle_stats_by_day_rpm_0;"
    self.connection.execute "DROP VIEW IF EXISTS vehicle_stats_by_day_no_rpm;"
    self.connection.execute "DROP VIEW IF EXISTS vehicle_stats_by_day_rpm_900;"
    self.connection.execute "DROP VIEW IF EXISTS vehicle_stats_by_day_rpm_1600;"
    self.connection.execute "DROP VIEW IF EXISTS vehicle_stats_by_day_percent_load;"
    self.connection.execute "DROP VIEW IF EXISTS vehicle_stats_by_day_oil_condition;"

    self.connection.execute "DROP VIEW IF EXISTS vehicle_stats_by_day;"

    remove_index :vehicle_stats, :date
    remove_index :vehicle_stats, :time
  end
end
