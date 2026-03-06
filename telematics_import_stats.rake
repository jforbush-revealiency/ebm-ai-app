require 'csv'

# ─────────────────────────────────────────────────────────────────────────────
# Replaces the import_stats task in telematics_pipeline.rake
# Reads column selection from TelematicsImportColumn config so only
# admin-selected columns are written to vehicle_stats.
# ─────────────────────────────────────────────────────────────────────────────
namespace :telematics do
  desc "Import Monico CSV using admin-configured column selection"
  task import_stats: :environment do
    file         = ENV['FILE'] || raise("Usage: rails telematics:import_stats FILE=path/to/file.csv")
    vehicle_code = ENV['VEHICLE']

    raise "File not found: #{file}" unless File.exist?(file)

    # ── Resolve vehicle and column config ──────────────────────────────────
    vehicle = vehicle_code ? Vehicle.find_by!(code: vehicle_code) : detect_vehicle_from_csv(file)
    col_config = TelematicsImportColumn
                   .where(vehicle: vehicle)
                   .or(TelematicsImportColumn.where(location: vehicle.location, vehicle: nil))
                   .order(vehicle_id: :desc)  # vehicle-specific wins over location default
                   .first

    unless col_config
      puts "No column config found for #{vehicle.code}. Run seed first or use the admin UI."
      exit 1
    end

    # Build map of csv_column → db_column for enabled columns only
    import_map = col_config.column_map
                           .select { |_, cfg| cfg['enabled'] == true && cfg['db_column'].present? }
                           .transform_values { |cfg| cfg['db_column'] }

    puts "Importing: #{file}"
    puts "Vehicle:   #{vehicle.code}"
    puts "Columns:   #{import_map.size} enabled (of #{col_config.column_map.size} total)"
    puts "Skipping:  #{col_config.column_map.count { |_, v| !v['enabled'] }} columns"
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

        # Idempotent — skip if already imported
        if VehicleStat.exists?(code: vehicle.code, filename: filename, datetime: dt)
          skipped += 1
          next
        end

        # Build attributes from only the enabled + mapped columns
        attrs = {
          code:     vehicle.code,
          filename: filename,
          date:     dt.to_date,
          time:     dt.strftime('%H:%M:%S'),
          datetime: dt,
        }

        import_map.each do |csv_col, db_col|
          raw = row[csv_col]
          next if raw.nil?  # CSV column not present in this file

          attrs[db_col.to_sym] = case raw.strip
                                 when '' then nil
                                 else raw.strip.to_f rescue nil
                                 end
        end

        stat = VehicleStat.new(attrs)
        stat.save!(validate: false)
        imported += 1
        print '.' if imported % 500 == 0

      rescue => e
        errors += 1
        puts "\nError on row #{imported + skipped + errors}: #{e.message}" if errors <= 5
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

  private

  def detect_vehicle_from_csv(file)
    first_code = CSV.foreach(file, headers: true).first&.[]('code')&.strip
    raise "Cannot detect vehicle from CSV — pass VEHICLE= explicitly" if first_code.blank?
    Vehicle.find_by!(code: first_code)
  end
end
