require 'csv'

namespace :telematics do

  desc "Import Monico CSV using admin-configured column selection"
  task import_stats: :environment do
    file         = ENV['FILE'] || Rails.root.join('tmp/import/Data_dump_csv.csv').to_s
    vehicle_code = ENV['VEHICLE']

    unless File.exist?(file)
      puts "ERROR: File not found: #{file}"
      exit 1
    end

    vehicle = if vehicle_code.present?
      Vehicle.find_by!(code: vehicle_code)
    else
      first_code = CSV.foreach(file, headers: true).first&.[]('code')&.strip
      raise "Cannot detect vehicle from CSV — pass VEHICLE= explicitly" if first_code.blank?
      Vehicle.find_by!(code: first_code)
    end

    col_config = TelematicsImportColumn
                   .where(vehicle: vehicle)
                   .or(TelematicsImportColumn.where(location: vehicle.location, vehicle: nil))
                   .order(vehicle_id: :desc)
                   .first

    unless col_config
      puts "No column config found for #{vehicle.code}. Run seed first."
      exit 1
    end

    import_map = col_config.enabled_map

    puts "Importing: #{file}"
    puts "Vehicle:   #{vehicle.code}"
    puts "Columns:   #{import_map.size} enabled"
    puts ""

    imported = 0
    skipped  = 0
    errors   = 0

    CSV.foreach(file, headers: true, encoding: 'bom|utf-8') do |row|
      next if row['code'].blank?

      begin
        date_str = row['date'].to_s.strip
        time_str = row['time'].to_s.strip
        next if date_str.blank? || time_str.blank?

        dt = DateTime.strptime("#{date_str} #{time_str}", '%m/%d/%Y %H:%M:%S') rescue nil
        next if dt.nil?

        filename = row['filename'].to_s.strip

        if VehicleStat.exists?(code: vehicle.code, filename: filename, datetime: dt)
          skipped += 1
          next
        end

        attrs = {
          code:     vehicle.code,
          filename: filename,
          date:     dt.to_date,
          time:     dt.strftime('%H:%M:%S'),
          datetime: dt,
        }

        import_map.each do |csv_col, db_col|
          raw = row[csv_col]
          next if raw.nil?
          attrs[db_col.to_sym] = raw.strip.empty? ? nil : raw.strip.to_f rescue nil
        end

        VehicleStat.new(attrs).save!(validate: false)
        imported += 1
        print '.' if imported % 500 == 0

      rescue => e
        errors += 1
        puts "\nError on row #{imported + skipped + errors}: #{e.class} — #{e.message}" if errors <= 3
        puts e.backtrace.first if errors <= 3
      end
    end

    puts "\n"
    puts "=== Import Complete ==="
    puts "Imported : #{imported}"
    puts "Skipped  : #{skipped} (already in DB)"
    puts "Errors   : #{errors}"
    puts ""
    puts "Next: rails telematics:process_iso8178 VEHICLE=#{vehicle.code}"
  end

  desc "Detect ISO 8178 windows in vehicle_stats and create valid_emission_tests"
  task process_iso8178: :environment do
    vehicle_code = ENV['VEHICLE']
    date_filter  = ENV['DATE']

    configs = TelematicsConfig.where(enabled: true)
    configs = configs.joins(:vehicle).where(vehicles: { code: vehicle_code }) if vehicle_code.present?

    if configs.empty?
      puts "No active telematics configs found. Run the seed first."
      exit 1
    end

    total_tests_created = 0

    configs.each do |config|
      vehicle  = config.vehicle
      location = config.location

      puts "\nProcessing: #{vehicle.code}"
      puts "  ISO 8178 thresholds: load >= #{config.min_load_percent}%  RPM >= #{config.min_rpm}"
      puts "  Frequency gate: max 1 test per #{config.test_frequency_hours} hours"

      stats = VehicleStat.where(code: vehicle.code).order(:datetime)
      stats = stats.where(date: Date.parse(date_filter)) if date_filter.present?

      if stats.empty?
        puts "  No vehicle stats found. Run telematics:import_stats first."
        next
      end

      puts "  Processing #{stats.count} readings..."

      tests_created    = 0
      last_test_time   = nil
      stats_array      = stats.to_a
      i                = 0
      fail_load_rpm    = 0
      fail_timespan    = 0
      fail_consistency = 0
      fail_frequency   = 0

      while i <= stats_array.length - config.sample_count
        window = stats_array[i, config.sample_count]

        all_qualify = window.all? do |s|
          s.percent_load.to_f >= config.min_load_percent &&
          s.rpm.to_f          >= config.min_rpm
        end

        unless all_qualify
          fail_load_rpm += 1
          i += 1
          next
        end

        expected_span = (config.sample_count - 1) * config.sample_interval_seconds
        actual_span   = (window.last.datetime - window.first.datetime).to_f * 86400
        unless (actual_span - expected_span).abs < (config.sample_interval_seconds * 1.5)
          fail_timespan += 1
          i += 1
          next
        end

        unless readings_are_consistent?(window, config.consistency_threshold_pct)
          fail_consistency += 1
          i += 1
          next
        end

        window_time = window.first.datetime
        if last_test_time && (window_time - last_test_time).to_f * 24 < config.test_frequency_hours
          fail_frequency += 1
          i += config.sample_count
          next
        end

        if ValidEmissionTest.exists?(code: vehicle.code, datetime: window_time)
          last_test_time = window_time
          i += config.sample_count
          next
        end

        avg = average_window(window)

        begin
          ValidEmissionTest.create!(
            code:                  vehicle.code,
            datetime:              window_time,
            date:                  window_time.to_date,
            percent_load:          avg[:percent_load].round,
            rpm:                   avg[:rpm].round,
            boost_psi:             avg[:boost_psi]&.round(3),
            fuel_gallons_per_hour: avg[:fuel_gallons_per_hour]&.round(4),
            nox_ppm:               avg[:nox_ppm]&.round(2),
            co2_percent:           avg[:co2_percent]&.round(4),
            batch:                 "#{vehicle.code}_#{window_time.strftime('%Y%m%d')}"
          )

          last_test_
