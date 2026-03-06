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
          nex
