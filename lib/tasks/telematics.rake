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

          last_test_time = window_time
          tests_created  += 1
          total_tests_created += 1
          i += config.sample_count

        rescue => e
          puts "\n  Error creating test at #{window_time}: #{e.message}"
          i += 1
        end
      end

      puts "  Rejected — load/rpm: #{fail_load_rpm}  timespan: #{fail_timespan}  consistency: #{fail_consistency}  frequency: #{fail_frequency}"
      puts "  Created #{tests_created} valid emission tests"
    end

    puts "\n=== ISO 8178 Processing Complete ==="
    puts "Total valid emission tests created: #{total_tests_created}"
  end

  desc "Accumulate daily valid_emission_tests into Input + Output daily report"
  task generate_daily_reports: :environment do
    vehicle_code = ENV['VEHICLE']
    date_filter  = ENV['DATE']

    configs = TelematicsConfig.where(enabled: true)
    configs = configs.joins(:vehicle).where(vehicles: { code: vehicle_code }) if vehicle_code.present?

    imports_user = User.find_by(role: 'imports')
    unless imports_user
      puts "ERROR: No imports user found. Run the seed first."
      exit 1
    end

    reports_created = 0
    reports_skipped = 0

    configs.each do |config|
      vehicle  = config.vehicle
      location = config.location

      puts "\nGenerating daily reports for: #{vehicle.code}"

      tests_scope = ValidEmissionTest.where(code: vehicle.code)
      tests_scope = tests_scope.where(date: Date.parse(date_filter)) if date_filter.present?

      dates = tests_scope.distinct.pluck(:date).sort

      if dates.empty?
        puts "  No valid emission tests found. Run telematics:process_iso8178 first."
        next
      end

      puts "  Found valid tests on #{dates.length} date(s)"

      dates.each do |date|
        day_tests = ValidEmissionTest.where(code: vehicle.code, date: date)
        count     = day_tests.count

        existing = Input.where(vehicle: vehicle, auto_generated: true)
                        .where("DATE(submitted) = ?", date).exists?
        if existing
          reports_skipped += 1
          next
        end

        avg_nox  = day_tests.average(:nox_ppm).to_f
        avg_co2  = day_tests.average(:co2_percent).to_f
        avg_rpm  = day_tests.average(:rpm).to_f

        latest_stat  = VehicleStat.where(code: vehicle.code, date: date).order(:datetime).last
        engine_hours = latest_stat&.lifetime_operating_hours.to_f

        begin
          Input.transaction do
            input = Input.new(
              location:               location,
              vehicle:                vehicle,
              user:                   imports_user,
              company_code:           location.company.code,
              location_code:          location.code,
              vehicle_code:           vehicle.code,
              submitter_first_name:   'Telematics',
              submitter_last_name:    'System',
              submitter_email:        imports_user.email,
              submitted:              date.to_datetime.end_of_day,
              engine_hours:           engine_hours > 0 ? engine_hours : nil,
              engine_rpm:             avg_rpm.round(1),
              left_bank_co2_percent:  avg_co2 / 100.0,
              right_bank_co2_percent: 0.0,
              left_bank_nox:          avg_nox,
              auto_generated:         true,
              has_engine_codes:       false
            )
            input.save!(validate: false)

            begin
              Output.process_input(input)
              puts "  #{date}: #{count} tests averaged → daily report Input ##{input.id}"
              reports_created += 1
            rescue => e
              puts "  #{date}: Input ##{input.id} saved, output failed — #{e.message}"
              reports_created += 1
            end
          end
        rescue => e
          puts "  ERROR on #{date}: #{e.message}"
        end
      end
    end

    puts "\n=== Daily Reports Complete ==="
    puts "Created: #{reports_created}  |  Skipped: #{reports_skipped}"
  end

  desc "Run full pipeline: import_stats → process_iso8178 → generate_daily_reports"
  task run_pipeline: [:import_stats, :process_iso8178, :generate_daily_reports] do
    puts "\n=== Full Telematics Pipeline Complete ==="
  end

  desc "Update telematics test frequency and thresholds for a vehicle"
  task set_frequency: :environment do
    vehicle_code = ENV['VEHICLE']
    hours        = ENV['HOURS']&.to_f
    min_load     = ENV['LOAD']&.to_f
    min_rpm      = ENV['RPM']&.to_f

    unless vehicle_code && hours
      puts "Usage: rails telematics:set_frequency VEHICLE=redmond_ht4 HOURS=4 [LOAD=90 RPM=1750]"
      exit 1
    end

    vehicle = Vehicle.find_by!(code: vehicle_code)
    config  = TelematicsConfig.find_by!(vehicle: vehicle)

    config.test_frequency_hours = hours
    config.min_load_percent     = min_load if min_load
    config.min_rpm              = min_rpm  if min_rpm
    config.save!(validate: false)

    puts "Updated #{vehicle_code}: freq=#{config.test_frequency_hours}h  load>=#{config.min_load_percent}%  rpm>=#{config.min_rpm}"
  end

  desc "Show telematics pipeline status"
  task status: :environment do
    puts "\n=== Telematics Pipeline Status ==="
    TelematicsConfig.where(enabled: true).each do |config|
      v = config.vehicle
      puts "\nVehicle: #{v.code}  (#{v.description})"
      puts "  Thresholds:    load >= #{config.min_load_percent}%  rpm >= #{config.min_rpm}  freq = #{config.test_frequency_hours}h"
      puts "  Raw stats:     #{VehicleStat.where(code: v.code).count} readings"
      tests = ValidEmissionTest.where(code: v.code)
      puts "  Valid tests:   #{tests.count} across #{tests.distinct.pluck(:date).length} days"
      puts "  Daily reports: #{Input.where(vehicle: v, auto_generated: true).count}"
      tests.group(:date).count.sort.each { |d, n| puts "    #{d}: #{n} tests" }
    end
  end

  private

  def readings_are_consistent?(window, threshold_pct)
    [:nox_ppm, :co2_percent, :rpm, :percent_load].each do |field|
      values = window.map { |s| s.send(field).to_f }.reject(&:zero?)
      next if values.length < 2
      mean = values.sum / values.length
      next if mean.zero?
      return false if values.map { |v| ((v - mean).abs / mean * 100) }.max > threshold_pct
    end
    true
  end

  def average_window(window)
    [:percent_load, :rpm, :nox_ppm, :co2_percent, :o2_percent,
     :boost_psi, :fuel_gallons_per_hour, :coolant_temperature,
     :left_exhaust_temperature, :right_exhaust_temperature,
     :throttle_position, :oil_pressure_psi].each_with_object({}) do |field, avg|
      values = window.map { |s| s.send(field).to_f }.compact
      avg[field] = values.empty? ? nil : values.sum / values.length
    end
  end

end

