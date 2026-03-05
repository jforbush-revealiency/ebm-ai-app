require 'aws-sdk'
require 'csv'

class VehicleStat < ApplicationRecord

  def self.import_time_zone
    "America/Denver"
  end

  def self.import_stat_files(bucket_name, vehicle_data_code, after_filename)
    s3 = Aws::S3::Resource.new(region: 'us-west-2')
    bucket = s3.bucket(bucket_name)
    objects = bucket.objects({ prefix: "#{vehicle_data_code}/logs/data"}).sort do |a,b|
      a.key.downcase <=> b.key.downcase
    end
    objects.each do |b|
      if b.size > 0
        filename = File.basename(b.key)
        if after_filename.blank? || filename > after_filename
          self.import_stat_file(bucket_name, b.key) 
        end
      end
    end
  end

  def self.import_stat_file(bucket_name, file_key)
    filename = File.basename(file_key)
    vehicle_data_code = file_key.split("/").first
    s3 = Aws::S3::Resource.new(region: 'us-west-2')
    bucket = s3.bucket(bucket_name)

    object = bucket.object(file_key).get()
    data = object.body.read
    if object.content_length == 0
      import_log = VehicleStatImportLog.new
      import_log.code = vehicle_data_code
      import_log.filename = filename
      import_log.status = "ERROR"
      import_log.log = "The #{file_key} file is empty."
      import_log.save
    elsif data.valid_encoding?
      file_format_version = "v4"
      first_newline_position = (data.index("\n") || data.size - 1) + 1
      first_row = data[0..first_newline_position]

      # Sometimes the header line isn't present and so we can't remove
      # the first line
      if self.all_letters(first_row[0])
        data.slice!(0, first_newline_position).sub("\n",'')
      end

      num_columns = first_row.split(",").length

      if num_columns == 135
        data.prepend(csv_header_row_v2().join(",") << "\r\n")
      file_format_version = "v2"
      elsif num_columns == 137
        data.prepend(csv_header_row_v3().join(",") << "\r\n")
        file_format_version = "v3"
      elsif num_columns == 155
        data.prepend(csv_header_row_v1().join(",") << "\r\n")
        file_format_version = "v1"
      elsif num_columns == 33 
        data.prepend(csv_header_row_v4().join(",") << "\r\n")
        file_format_version = "v4"
      elsif num_columns == 35 
        # this was added because Monico added a couple of columns at the end of the data
        # to see what was happening to their unit.  We don't need those two extra columns
        # So we will ignore them.
        data.prepend(csv_header_row_v4().join(",") << "\r\n")
        file_format_version = "v4"
      else
        import_log = VehicleStatImportLog.new
        import_log.code = vehicle_data_code
        import_log.filename = filename
        import_log.status = "ERROR"
        import_log.log = "Malformed CSV header in file #{file_key} file.  It has #{num_columns} columns and it should have either 33, 35, 135, 137, or 155 columns."
        import_log.save

        return import_log
      end

      VehicleStat.where(code: vehicle_data_code, filename: filename).delete_all
      line_number = 1
      zero_rpm = 0
      begin
        CSV.parse(data, headers: true) do |row|
          if row["rpm"].to_i > 0
            VehicleStat.create_vehicle_stat(line_number, vehicle_data_code, filename, file_key, row, file_format_version) 
          else
            zero_rpm += 1
          end
          line_number += 1
        end
        import_log = VehicleStatImportLog.new
        import_log.code = vehicle_data_code
        import_log.filename = filename
        import_log.status = "SUCCESS"
        import_log.log = "The CSV file #{file_key} was successfully imported with #{line_number-=1} data rows (excluding the header).  #{zero_rpm} lines were excluded because of 0 RPMs. It used file format version #{file_format_version}."
        import_log.save
      rescue CSV::MalformedCSVError => e
        import_log = VehicleStatImportLog.new
        import_log.code = vehicle_data_code
        import_log.filename = filename
        import_log.status = "ERROR"
        import_log.log = "Malformed CSV file #{file_key} file is not a valid CSV file. It used file format version #{file_format_version}. The exception is: #{e.message}"
        import_log.save
      end
    else
      import_log = VehicleStatImportLog.new
      import_log.code = vehicle_data_code
      import_log.filename = filename
      import_log.status = "ERROR"
      import_log.log = "The #{file_key} file is not a valid CSV file."
      import_log.save
    end

    import_log
  end

  def self.create_vehicle_stat(line_number, code, filename, full_path, row, file_format_version)
    vehicle_stat_hash = row.to_hash

    if file_format_version == "v1"
      attributes_not_needed_v1.each do |attribute|
        vehicle_stat_hash.except!(attribute)
      end
    end

    # check for any nil hash keys.
    # this means they aren't mapped to any file format and we should
    # ignore them.  This is safe because the code checks the length of the 
    # rows and assigns a file format version before we get here.
    # If we get here then the previous checks determined it was safe
    # therefore we should ignore any unmapped keys.
    vehicle_stat_hash.delete_if {|k,v| k.nil?}

    begin
      datetime = Time.parse(row["date"] + " " + row["time"])
      vehicle_stat = VehicleStat.new
      vehicle_stat.code = code
      vehicle_stat.filename = filename
      vehicle_stat.datetime = datetime
      vehicle_stat.date = datetime
      vehicle_stat.time = datetime
      vehicle_stat.update_attributes(vehicle_stat_hash)
    rescue ArgumentError => e
      import_log = VehicleStatImportLog.new
      import_log.code = code
      import_log.filename = filename
      import_log.status = "ERROR"
      import_log.log = "Line number #{line_number} doesn't have valid information in the #{full_path} file. The exception is: #{e.message}"
      import_log.save
    end
  end

  def self.attributes_not_needed_v1
    return [
            "date",
            "time",
            "CDL5_ENGINE_TYPE", # not needed
            "CDL8_IGN_TIMING_CAL", # not needed
            "CDL15_ENG_CONTROL_SW_POS", # not needed
            "CDL41_ENG_OPERATION", # not needed
            "CDL76_GENSET_HOURS", # not needed
            "CDL77_ENGINE_STATUS", # not needed
            "CDL115_CYCLE_CRANK_T_SP", # not needed
            "CDL265_ENG_POW_DERATE", # not needed
            "CDL266_ACTUAL_ENG_TIMING", # not needed
            "CDL280_EFF_RACK_MM",  # not needed
            "CDL281_EFF_RACK_LIM_MM",  # not needed
            "CDL410_DEL_FUEL_VOL_IN3", # not needed
            "CDL589_FUEL_RAIL2_PRS", # not needed
    ]
  end

  def self.csv_header_row_v1()
    return ["date", 
            "time",
            "CDL5_ENGINE_TYPE", # not needed
            "CDL8_IGN_TIMING_CAL", # not needed
            "CDL15_ENG_CONTROL_SW_POS", # not needed
            "CDL41_ENG_OPERATION", # not needed
            "percent_load", 
            "rpm",
            "coolant_temperature",
            "CDL76_GENSET_HOURS", # not needed
            "CDL77_ENGINE_STATUS", # not needed
            "right_exhaust_temperature",
            "left_exhaust_temperature",
            "CDL115_CYCLE_CRANK_T_SP", # not needed
            "ecm_oil_temperature",
            "warning_status",
            "shutdown_status",
            "derate_warning",
            "warning_2",
            "shutdown_2",
            "throttle_position",
            "system_voltage",
            "CDL265_ENG_POW_DERATE", # not needed
            "CDL266_ACTUAL_ENG_TIMING", # not needed
            "atmospheric_pressure",
            "oil_pressure_psi",
            "boost_psi",
            "filter_oil_pressure",
            "boost_abs_psi",
            "CDL280_EFF_RACK_MM",  # not needed
            "CDL281_EFF_RACK_LIM_MM",  # not needed
            "smoke_setting",
            "intake_air_temperature",
            "fuel_temperature",
            "fuel_gallons_per_hour", 
            "lifetime_fuel_consumption",
            "lifetime_operating_hours",
            "fuel_rate",
            "CDL410_DEL_FUEL_VOL_IN3", # not needed
            "duty_cycle_t1",
            "duty_cycle_t2",
            "duty_cycle_t3",
            "lifetime_idle_hours",
            "lifetime_idle_fuel",
            "CDL589_FUEL_RAIL2_PRS", # not needed
            "fault_high_exhaust_temperature_warning",
            "fault_engine_overspeed_warning",
            "fault_low_coolant_temperature_warning",
            "fault_high_coolant_temperature_warning",
            "fault_low_engine_oil_pressure_warning",
            "fault_low_system_volts_warning",
            "fault_high_air_temperature_warning",
            "fault_high_oil_temperature_warning",
            "fault_high_hydraulic_oil_temperature_warning",
            "fault_no_coolant_flow_warning",
            "fault_high_after_coolant_temperature_warning",
            "fault_high_crankcase_pressure_warning",
            "fault_fuel_filer_plugged_warning",
            "fault_oil_filer_plugged_warning",
            "fault_low_coolant_level_warning",
            "fault_alternator_not_charging_warning",
            "fault_low_fuel_level_warning",
            "fault_low_fuel_pressure_warning",
            "fault_high_fuel_temperature_warning",
            "fault_low_intake_manifold_pressure_warning",
            "fault_high_intake_manifold_pressure_warning",
            "fault_low_oil_level_warning",
            "fault_engine_oil_bypass_warning",
            "fault_high_exhaust_temperature_shutdown",
            "fault_air_filter_plugged_shutdown",
            "fault_engine_overspeed_shutdown",
            "fault_low_engine_coolant_temperature_shutdown",
            "fault_high_engine_coolant_temperature_shutdown",
            "fault_low_engine_oil_pressure_shutdown",
            "fault_low_system_volts_shutdown",
            "fault_high_engine_airintake_temperature_shutdown",
            "fault_high_engine_oil_temperature_shutdown",
            "fault_high_crankcase_pressure_shutdown",
            "fault_fuel_filter_plugged_shutdown",
            "fault_oil_filter_plugged_shutdown",
            "fault_low_coolant_level_shutdown",
            "fault_alternator_not_charging_shutdown",
            "fault_low_fuel_level_shutdown",
            "fault_low_fuel_pressure_shutdown",
            "fault_high_fuel_temperature_shutdown",
            "fault_low_intake_manifold_pressure_shutdown",
            "fault_high_intake_manifold_pressure_shutdown",
            "fault_low_oil_level_shutdown",
            "fault_engine_oil_filter_bypass_shutdown",
            "fault_high_exhaust_temperature_derate",
            "fault_air_filter_plugged_derate",
            "fault_engine_overspeed_derate",
            "fault_low_engine_coolant_temperature_derate",
            "fault_high_engine_coolant_temperature_derate",
            "fault_low_engine_oil_pressure_derate",
            "fault_low_system_voltage_derate",
            "fault_high_engine_air_temperature_derate",
            "fault_high_engine_oil_temperature_derate",
            "fault_high_hydraulic_oil_temperature_derate",
            "fault_no_coolant_flow_derate",
            "fault_high_after_coolant_temperature_derate",
            "fault_high_crankcase_pressure_derate",
            "fault_fuel_filter_plugged_derate",
            "fault_oil_filter_plugged_derate",
            "fault_low_coolant_level_derate",
            "fault_alternator_not_charging_derate",
            "fault_low_fuel_level_derate",
            "fault_low_fuel_pressure_derate",
            "fault_high_fuel_temperature_derate",
            "fault_low_intake_manifold_pressure_derate",
            "fault_high_intake_manifold_pressure_derate",
            "fault_low_oil_level_shutdown_derate",
            "fault_engine_oil_filter_bypass_derate",
            "fault_high_engine_vibration_derate",
            "fault_low_oil_filter_pressure_derate",
            "fault_high_oil_filter_pressure_derate",
            "fault_high_engine_oil_pressure_derate",
            "fault_low_coolant_to_engine_oil_temperature_difference_derate",
            "fault_low_coolant_pressure_derate",
            "fault_low_coolant_level_derate",
            "fault_high_coolant_temperature_derate",
            "fault_low_exhaust_temperature_deviation_derate",
            "fault_high_exhaust_temperature_deviation_derate",
            "fault_high_exhaust_temperature_difference_derate",
            "fault_high_intake_manifold_air_temperature_derate",
            "fault_high_crankcase_metal_particulate_derate",
            "fault_high_pressure_oilline_broken_derate",
            "fault_high_injector_actuation_pressure_derate",
            "fault_high_fuel_cool_seperator_water_level_derate",
            "fault_high_fuel_rail_pump_flow_derate",
            "fault_low_inlet_air_temperature_derate",
            "fault_high_fuel_pressure_line_broken_derate",
            "fault_global_active_derate", 

            "is_cdl_online", 
            "nox_ppm", 
            "o2_percent", 
            "nox_signal_status", 
            "o2_signal_status",
            "nox_not_valid",
            "nox_valid",
            "nox_error",
            "nox_na",
            "nox_fmi_shorted",
            "nox_fmi_openwire",
            "o2_not_valid",
            "o2_valid",
            "o2_error",
            "o2_na",
            "o2_fmi_shorted",
            "o2_fmi_openwire",
            "colima_1",
            "colima_2",
            "sensor_oil_temperature",
            "ambient_temperature",
            "oil_condition"]
  end

  def self.csv_header_row_v2()
    return ["date", 
            "time",
            "percent_load", 
            "rpm",
            "coolant_temperature",
            "right_exhaust_temperature",
            "left_exhaust_temperature",
            "ecm_oil_temperature",
            "warning_status",
            "warning_2",
            "throttle_position",
            "system_voltage",
            "atmospheric_pressure",
            "oil_pressure_psi",
            "boost_psi",
            "filter_oil_pressure",
            "smoke_setting",
            "intake_air_temperature",
            "fuel_temperature",
            "fuel_gallons_per_hour",
            "lifetime_fuel_consumption",
            "lifetime_operating_hours",
            "fuel_rate",
            "lifetime_idle_hours",
            "lifetime_idle_fuel",
            "fault_high_exhaust_temperature_warning",
            "fault_engine_overspeed_warning",
            "fault_low_coolant_temperature_warning",
            "fault_high_coolant_temperature_warning",
            "fault_low_engine_oil_pressure_warning",
            "fault_low_system_volts_warning",
            "fault_high_air_temperature_warning",
            "fault_high_oil_temperature_warning",
            "fault_high_hydraulic_oil_temperature_warning",
            "fault_no_coolant_flow_warning",
            "fault_high_after_coolant_temperature_warning",
            "fault_high_crankcase_pressure_warning",
            "fault_fuel_filer_plugged_warning",
            "fault_oil_filer_plugged_warning",
            "fault_low_coolant_level_warning",
            "fault_alternator_not_charging_warning",
            "fault_low_fuel_level_warning",
            "fault_low_fuel_pressure_warning",
            "fault_high_fuel_temperature_warning",
            "fault_low_intake_manifold_pressure_warning",
            "fault_high_intake_manifold_pressure_warning",
            "fault_low_oil_level_warning",
            "fault_engine_oil_bypass_warning",
            "fault_high_exhaust_temperature_shutdown",
            "fault_air_filter_plugged_shutdown",
            "fault_engine_overspeed_shutdown",
            "fault_low_engine_coolant_temperature_shutdown",
            "fault_high_engine_coolant_temperature_shutdown",
            "fault_low_engine_oil_pressure_shutdown",
            "fault_low_system_volts_shutdown",
            "fault_high_engine_airintake_temperature_shutdown",
            "fault_high_engine_oil_temperature_shutdown",
            "fault_high_crankcase_pressure_shutdown",
            "fault_fuel_filter_plugged_shutdown",
            "fault_oil_filter_plugged_shutdown",
            "fault_low_coolant_level_shutdown",
            "fault_alternator_not_charging_shutdown",
            "fault_low_fuel_level_shutdown",
            "fault_low_fuel_pressure_shutdown",
            "fault_high_fuel_temperature_shutdown",
            "fault_low_intake_manifold_pressure_shutdown",
            "fault_high_intake_manifold_pressure_shutdown",
            "fault_low_oil_level_shutdown",
            "fault_engine_oil_filter_bypass_shutdown",
            "fault_high_exhaust_temperature_derate",
            "fault_air_filter_plugged_derate",
            "fault_engine_overspeed_derate",
            "fault_low_engine_coolant_temperature_derate",
            "fault_high_engine_coolant_temperature_derate",
            "fault_low_engine_oil_pressure_derate",
            "fault_low_system_voltage_derate",
            "fault_high_engine_air_temperature_derate",
            "fault_high_engine_oil_temperature_derate",
            "fault_high_hydraulic_oil_temperature_derate",
            "fault_no_coolant_flow_derate",
            "fault_high_after_coolant_temperature_derate",
            "fault_high_crankcase_pressure_derate",
            "fault_fuel_filter_plugged_derate",
            "fault_oil_filter_plugged_derate",
            "fault_low_coolant_level_derate",
            "fault_alternator_not_charging_derate",
            "fault_low_fuel_level_derate",
            "fault_low_fuel_pressure_derate",
            "fault_high_fuel_temperature_derate",
            "fault_low_intake_manifold_pressure_derate",
            "fault_high_intake_manifold_pressure_derate",
            "fault_low_oil_level_shutdown_derate",
            "fault_engine_oil_filter_bypass_derate",
            "fault_high_engine_vibration_derate",
            "fault_low_oil_filter_pressure_derate",
            "fault_high_oil_filter_pressure_derate",
            "fault_high_engine_oil_pressure_derate",
            "fault_low_coolant_to_engine_oil_temperature_difference_derate",
            "fault_low_coolant_pressure_derate",
            "fault_low_coolant_level_derate",
            "fault_high_coolant_temperature_derate",
            "fault_low_exhaust_temperature_deviation_derate",
            "fault_high_exhaust_temperature_deviation_derate",
            "fault_high_exhaust_temperature_difference_derate",
            "fault_high_intake_manifold_air_temperature_derate",
            "fault_high_crankcase_metal_particulate_derate",
            "fault_high_pressure_oilline_broken_derate",
            "fault_high_injector_actuation_pressure_derate",
            "fault_high_fuel_cool_seperator_water_level_derate",
            "fault_high_fuel_rail_pump_flow_derate",
            "fault_low_inlet_air_temperature_derate",
            "fault_high_fuel_pressure_line_broken_derate",
            "fault_global_active_derate", 
            "is_cdl_online", 
            "nox_ppm", 
            "o2_percent", 
            "nox_signal_status", 
            "o2_signal_status",
            "nox_not_valid",
            "nox_valid",
            "nox_error",
            "nox_na",
            "nox_fmi_shorted",
            "nox_fmi_openwire",
            "o2_not_valid",
            "o2_valid",
            "o2_error",
            "o2_na",
            "o2_fmi_shorted",
            "o2_fmi_openwire",
            "colima_1",
            "colima_2",
            "sensor_oil_temperature",
            "ambient_temperature",
            "oil_condition"]
  end

  def self.csv_header_row_v3()
    return ["date", 
            "time",
            "percent_load", 
            "rpm",
            "coolant_temperature",
            "right_exhaust_temperature",
            "left_exhaust_temperature",
            "ecm_oil_temperature",
            "warning_status",
            "warning_2",
            "throttle_position",
            "system_voltage",
            "atmospheric_pressure",
            "oil_pressure_psi",
            "boost_psi",
            "filter_oil_pressure",
            "smoke_setting",
            "intake_air_temperature",
            "fuel_temperature",
            "fuel_gallons_per_hour",
            "lifetime_fuel_consumption",
            "lifetime_operating_hours",
            "fuel_rate",
            "lifetime_idle_hours",
            "lifetime_idle_fuel",
            "fault_high_exhaust_temperature_warning",
            "fault_engine_overspeed_warning",
            "fault_low_coolant_temperature_warning",
            "fault_high_coolant_temperature_warning",
            "fault_low_engine_oil_pressure_warning",
            "fault_low_system_volts_warning",
            "fault_high_air_temperature_warning",
            "fault_high_oil_temperature_warning",
            "fault_high_hydraulic_oil_temperature_warning",
            "fault_no_coolant_flow_warning",
            "fault_high_after_coolant_temperature_warning",
            "fault_high_crankcase_pressure_warning",
            "fault_fuel_filer_plugged_warning",
            "fault_oil_filer_plugged_warning",
            "fault_low_coolant_level_warning",
            "fault_alternator_not_charging_warning",
            "fault_low_fuel_level_warning",
            "fault_low_fuel_pressure_warning",
            "fault_high_fuel_temperature_warning",
            "fault_low_intake_manifold_pressure_warning",
            "fault_high_intake_manifold_pressure_warning",
            "fault_low_oil_level_warning",
            "fault_engine_oil_bypass_warning",
            "fault_high_exhaust_temperature_shutdown",
            "fault_air_filter_plugged_shutdown",
            "fault_engine_overspeed_shutdown",
            "fault_low_engine_coolant_temperature_shutdown",
            "fault_high_engine_coolant_temperature_shutdown",
            "fault_low_engine_oil_pressure_shutdown",
            "fault_low_system_volts_shutdown",
            "fault_high_engine_airintake_temperature_shutdown",
            "fault_high_engine_oil_temperature_shutdown",
            "fault_high_crankcase_pressure_shutdown",
            "fault_fuel_filter_plugged_shutdown",
            "fault_oil_filter_plugged_shutdown",
            "fault_low_coolant_level_shutdown",
            "fault_alternator_not_charging_shutdown",
            "fault_low_fuel_level_shutdown",
            "fault_low_fuel_pressure_shutdown",
            "fault_high_fuel_temperature_shutdown",
            "fault_low_intake_manifold_pressure_shutdown",
            "fault_high_intake_manifold_pressure_shutdown",
            "fault_low_oil_level_shutdown",
            "fault_engine_oil_filter_bypass_shutdown",
            "fault_high_exhaust_temperature_derate",
            "fault_air_filter_plugged_derate",
            "fault_engine_overspeed_derate",
            "fault_low_engine_coolant_temperature_derate",
            "fault_high_engine_coolant_temperature_derate",
            "fault_low_engine_oil_pressure_derate",
            "fault_low_system_voltage_derate",
            "fault_high_engine_air_temperature_derate",
            "fault_high_engine_oil_temperature_derate",
            "fault_high_hydraulic_oil_temperature_derate",
            "fault_no_coolant_flow_derate",
            "fault_high_after_coolant_temperature_derate",
            "fault_high_crankcase_pressure_derate",
            "fault_fuel_filter_plugged_derate",
            "fault_oil_filter_plugged_derate",
            "fault_low_coolant_level_derate",
            "fault_alternator_not_charging_derate",
            "fault_low_fuel_level_derate",
            "fault_low_fuel_pressure_derate",
            "fault_high_fuel_temperature_derate",
            "fault_low_intake_manifold_pressure_derate",
            "fault_high_intake_manifold_pressure_derate",
            "fault_low_oil_level_shutdown_derate",
            "fault_engine_oil_filter_bypass_derate",
            "fault_high_engine_vibration_derate",
            "fault_low_oil_filter_pressure_derate",
            "fault_high_oil_filter_pressure_derate",
            "fault_high_engine_oil_pressure_derate",
            "fault_low_coolant_to_engine_oil_temperature_difference_derate",
            "fault_low_coolant_pressure_derate",
            "fault_low_coolant_level_derate",
            "fault_high_coolant_temperature_derate",
            "fault_low_exhaust_temperature_deviation_derate",
            "fault_high_exhaust_temperature_deviation_derate",
            "fault_high_exhaust_temperature_difference_derate",
            "fault_high_intake_manifold_air_temperature_derate",
            "fault_high_crankcase_metal_particulate_derate",
            "fault_high_pressure_oilline_broken_derate",
            "fault_high_injector_actuation_pressure_derate",
            "fault_high_fuel_cool_seperator_water_level_derate",
            "fault_high_fuel_rail_pump_flow_derate",
            "fault_low_inlet_air_temperature_derate",
            "fault_high_fuel_pressure_line_broken_derate",
            "fault_global_active_derate", 
            "is_cdl_online", 
            "nox_ppm", 
            "o2_percent", 
            "nox_signal_status", 
            "o2_signal_status",
            "nox_not_valid",
            "nox_valid",
            "nox_error",
            "nox_na",
            "nox_fmi_shorted",
            "nox_fmi_openwire",
            "o2_not_valid",
            "o2_valid",
            "o2_error",
            "o2_na",
            "o2_fmi_shorted",
            "o2_fmi_openwire",
            "colima_1",
            "colima_2",
            "sensor_oil_temperature",
            "ambient_temperature",
            "oil_condition"]
  end

  def self.csv_header_row_v4()
    return ["date", 
            "time",
            "percent_load", 
            "rpm",
            "coolant_temperature",
            "right_exhaust_temperature",
            "left_exhaust_temperature",
            "throttle_position",
            "system_voltage",
            "oil_pressure_psi",
            "boost_psi",
            "filter_oil_pressure",
            "smoke_setting",
            "intake_air_temperature",
            "fuel_temperature",
            "fuel_gallons_per_hour",
            "lifetime_fuel_consumption",
            "lifetime_operating_hours",
            "fuel_rate",
            "lifetime_idle_hours",
            "lifetime_idle_fuel",
            "nox_ppm", 
            "o2_percent", 
            "oil_temperature",
            "oil_condition", 
            "co", 
            "hydrocarbons", 
            "heater_voltage", 
            "heater_current", 
            "fuel_level_percent", 
            "fuel_gallons", 
            "truck_payload_tons", 
            "truck_miles_traveled"
    ]
  end

  def is_partially_blank(check_fields)
    check_fields.each do |field| 
      if self[field].blank?
        return true    
      end
    end
    return false
  end

  def self.to_csv(vehicle_stats)
    #Time.use_zone(self.import_time_zone) do
    all_fields = [:code, :filename].concat(csv_header_row_v4).insert(24, :co2_percent)
      CSV.generate do |csv|
        csv << all_fields 
        vehicle_stats.each do |vehicle_stat|
          co2_and_o2_percent = 18.3
          output = []
          #unless vehicle_stat.is_partially_blank(all_fields)
            all_fields.each do |field| 
              if field == "date"
                output << vehicle_stat[field].to_time.strftime("%Y-%m-%d")
              elsif field == "time"
                output << vehicle_stat[field].to_time.strftime("%H:%M:%S")
              elsif field == :co2_percent 
                o2_percent = vehicle_stat["o2_percent"]
                o2_percent = 0 if o2_percent.nil?
                if o2_percent > co2_and_o2_percent 
                  output << 0
                else
                  output << co2_and_o2_percent - o2_percent
                end
              else
                output << vehicle_stat[field]
              end
            end
            csv << output
          #end
        end
      end
    #end
  end

  def self.all_letters(str)
    # Use 'str[/[a-zA-Z]*/] == str' to let all_letters
    # yield true for the empty string
    str[/[a-zA-Z]+/]  == str
  end
end
