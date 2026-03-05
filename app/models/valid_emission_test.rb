class ValidEmissionTest < ApplicationRecord
  belongs_to :vehicle_stat

  def self.import_time_zone
    "America/Denver"
  end

  def self.analyze_emissions_data(start_date, end_date)
    all_vehicles = Vehicle.includes(:engine_config, location: :company).all.order("companies.code, locations.code, vehicles.code")
    (start_date..end_date).each do |date|
      all_vehicles.each do |vehicle|
        ValidEmissionTest.analyze_emissions_by_date(vehicle, date, Time.now.strftime("%Y%m%d%H%M%S"))
      end
    end
  end

  def self.analyze_emissions_by_date(vehicle, date, batch_id)
    co2_plus_o2_percent = vehicle.engine_config.default_co2_plus_o2_percent
    test_percent_load = vehicle.engine_config.default_test_percent_load
    test_rpm = vehicle.engine_config.default_test_rpm
    test_boost_psi = vehicle.engine_config.default_test_boost_psi
    test_fuel_gallons_per_hour = vehicle.engine_config.default_test_fuel_gallons_per_hour

    puts "CO2+O2%: #{co2_plus_o2_percent} Test Percent Load: #{test_percent_load} Test RPM: #{test_rpm} Test Boost PSI: #{test_boost_psi} Test Fuel Gallons/Hour: #{test_fuel_gallons_per_hour}"

    vehicle_stats = VehicleStat.where("code = ? and date = ?", vehicle.folder_code, date).order("date, time")

    ValidEmissionTest.where("code = ? and date = ?", vehicle.folder_code, date).delete_all
    
    consecutive_n_records = []
    vehicle_stats.each_with_index do |vehicle_stat, index|
      consecutive_n_records.clear
      consecutive_n_records << vehicle_stats[index]
      consecutive_n_records << vehicle_stats[index + 1] if index + 1 <= vehicle_stats.length
      consecutive_n_records << vehicle_stats[index + 2] if index + 2 <= vehicle_stats.length

      data_points = 0;
      total_percent_load = 0;
      total_rpm = 0;
      consecutive_n_records.each do |consecutive_n_record|
        unless consecutive_n_record.nil?
          total_percent_load += consecutive_n_record.percent_load
          total_rpm += consecutive_n_record.rpm
          data_points += 1
        end
      end

      average_percent_load = total_percent_load / data_points
      average_rpm = total_rpm / data_points

      if data_points >=3 && average_percent_load >= test_percent_load && average_rpm >= test_rpm
        consecutive_n_record = consecutive_n_records.last
        if consecutive_n_record.boost_psi >= test_boost_psi && consecutive_n_record.fuel_gallons_per_hour >= test_fuel_gallons_per_hour
          valid_emission_test = ValidEmissionTest.new
          valid_emission_test.batch = batch_id 
          valid_emission_test.vehicle_stat_id = consecutive_n_record.id
          valid_emission_test.code = consecutive_n_record.code
          valid_emission_test.datetime= consecutive_n_record.datetime
          valid_emission_test.date= consecutive_n_record.date
          valid_emission_test.time= consecutive_n_record.time
          #valid_emission_test.percent_load = average_percent_load
          #valid_emission_test.rpm = average_rpm
          valid_emission_test.percent_load = consecutive_n_record.percent_load
          valid_emission_test.rpm = consecutive_n_record.rpm
          valid_emission_test.boost_psi = consecutive_n_record.boost_psi
          valid_emission_test.fuel_gallons_per_hour = consecutive_n_record.fuel_gallons_per_hour
          valid_emission_test.nox_ppm = consecutive_n_record.nox_ppm
          valid_emission_test.co2_percent = co2_plus_o2_percent - consecutive_n_record.o2_percent

          valid_emission_test.save

          puts "#{consecutive_n_record.code} #{consecutive_n_record.date.strftime("%Y-%m-%d")} #{consecutive_n_record.time.strftime("%H:%M:%S")} #{consecutive_n_record.percent_load} #{consecutive_n_record.rpm} #{consecutive_n_record.boost_psi} #{consecutive_n_record.fuel_gallons_per_hour} #{average_percent_load} #{average_rpm}"
        end
      end
    end

    emission_tests = ValidEmissionTest.where("code = ? and date = ?", vehicle.folder_code, date)
    if emission_tests.size > 0
      # Create the Emissions Test
      vehicle = Vehicle.find_by(folder_code: vehicle.folder_code)
      location = vehicle.location 
      last_vehicle_stat = vehicle_stats.last

      auto_user = User.find_by(email: ENV.fetch("ADMIN_EMAIL", "admin@yourdomain.com"))

      data_points = 0;
      total_percent_load = 0;
      total_rpm = 0;
      total_boost_psi = 0;
      total_fuel_gallons_per_hour = 0;
      total_nox_ppm = 0;
      total_co2_percent = 0;
      emission_tests.each do |emission_test|
        total_percent_load += emission_test.percent_load
        total_rpm += emission_test.rpm
        total_boost_psi += emission_test.boost_psi
        total_fuel_gallons_per_hour += emission_test.fuel_gallons_per_hour
        total_nox_ppm += emission_test.nox_ppm
        total_co2_percent += emission_test.co2_percent
        data_points += 1
      end

      average_percent_load = total_percent_load / data_points
      average_rpm = total_rpm / data_points
      average_boost_psi = total_boost_psi / data_points
      average_fuel_gallons_per_hour = total_fuel_gallons_per_hour / data_points
      average_nox_ppm = total_nox_ppm / data_points
      average_co2_percent = total_co2_percent / data_points

      input = Input.new do |i|
        i.auto_generated = true
        i.created_at = Time.now
        i.updated_at = Time.now
        i.vehicle_id = vehicle.id
        i.engine_hours = last_vehicle_stat.lifetime_operating_hours
        i.has_engine_codes = false
        i.has_latest_configuration_file = "Yes"
        i.engine_rpm = average_percent_load 
        i.left_bank_co2_percent = average_co2_percent
        i.left_bank_nox = average_nox_ppm
      end
      input_results = input.commit(auto_user, location)
      if input_results 
        ProcessInputsJob.perform_later input
      end
    end
  end
end
