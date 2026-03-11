require 'csv'
namespace :import do
  desc "Import historical emission test data from CSV"
  task :emission_tests, [:file] => :environment do |t, args|
    file_path = args[:file] || Rails.root.join('tmp', 'import', 'Data_dump_csv.csv')
    unless File.exist?(file_path)
      puts "ERROR: File not found at #{file_path}"
      exit 1
    end

    import_user = User.find_by(role: 'imports') || User.find_by(role: 'site_admin')
    default_drive_type = DriveType.first || DriveType.create!(code: 'ELECTRIC', description: 'Electric')

    success_count = 0
    skip_count    = 0
    error_count   = 0
    errors        = []require 'csv'
namespace :import do
  desc "Import historical emission test data from CSV"
  task :emission_tests, [:file] => :environment do |t, args|
    file_path = args[:file] || Rails.root.join('tmp', 'import', 'Data_dump_csv.csv')
    unless File.exist?(file_path)
      puts "ERROR: File not found at #{file_path}"
      puts "Looked at: #{file_path}"
      # Don't exit with error - just skip import if no file
      next
    end

    import_user = User.find_by(role: 'imports') || User.find_by(role: 'site_admin')
    default_drive_type = DriveType.first || DriveType.create!(code: 'ELECTRIC', description: 'Electric')

    success_count = 0
    skip_count    = 0
    error_count   = 0
    errors        = []

    CSV.foreach(file_path, headers: true, encoding: 'bom|utf-8') do |row|
      begin
        # ------------------------------------------------------------------
        # Parse fields with safe handling for "Not measured" and "Single Stack"
        # ------------------------------------------------------------------
        vehicle_name   = row['Vehicle #'].to_s.strip
        vehicle_model  = row['Vehicle Model'].to_s.strip
        vehicle_serial = row['Vehicle Serial #'].to_s.strip
        engine_make    = row['Engine Make'].to_s.strip
        engine_model   = row['Engine Model'].to_s.strip
        company_name   = row['Company'].to_s.strip
        test_method    = row['Test Method'].to_s.strip.downcase  # "manual" or "telematic"

        # Handle the typo in the CSV header for Location
        location_name  = (row['Location'] || row['LoCaterpillarion'] || '').to_s.strip

        next if vehicle_name.blank? || company_name.blank?

        # Fix known typos
        engine_make = 'Caterpillar' if engine_make == 'Caterpillarerpillar'

        # ------------------------------------------------------------------
        # Company
        # ------------------------------------------------------------------
        company = Company.find_by("LOWER(description) = ?", company_name.downcase)
        company ||= Company.find_by("LOWER(code) = ?", company_name.parameterize.downcase)
        unless company
          company = Company.new(code: company_name.parameterize, description: company_name)
          company.save!(validate: false)
        end

        # ------------------------------------------------------------------
        # Location
        # ------------------------------------------------------------------
        loc_code = location_name.parameterize
        location = Location.find_by(code: loc_code, company_id: company.id)
        location ||= Location.find_by(code: loc_code)
        unless location
          location = Location.new(code: loc_code, description: location_name, company_id: company.id, attainment: false)
          location.save!(validate: false)
        end

        # ------------------------------------------------------------------
        # Manufacturer
        # ------------------------------------------------------------------
        manufacturer = Manufacturer.where("LOWER(description) = ?", engine_make.downcase).first
        manufacturer ||= Manufacturer.find_by("LOWER(code) = ?", engine_make.parameterize.downcase)
        unless manufacturer
          manufacturer = Manufacturer.new(code: engine_make.parameterize, description: engine_make)
          manufacturer.save!(validate: false)
        end

        # ------------------------------------------------------------------
        # Engine
        # ------------------------------------------------------------------
        is_single_stack = row['Right-CO2%'].to_s.strip == 'Single Stack'

        engine = Engine.find_by(code: engine_model)
        unless engine
          engine = Engine.new(
            code: engine_model,
            description: "#{engine_make} #{engine_model}",
            manufacturer_id: manufacturer.id,
            drive_type_id: default_drive_type.id,
            is_single_stack: is_single_stack
          )
          engine.save!(validate: false)
        end

        # ------------------------------------------------------------------
        # Engine Config — find existing canonical config first
        # ------------------------------------------------------------------
        engine_config = EngineConfig.find_by(engine_id: engine.id)
        unless engine_config
          engine_config = EngineConfig.new(
            engine_id: engine.id,
            code: engine_model,
            description: "#{engine_make} #{engine_model}",
            rated_rpm: safe_float(row['Engine RPM']),
            rated_hp: safe_float(row['Engine HP'])
          )
          engine_config.save!(validate: false)
        end

        # ------------------------------------------------------------------
        # Vehicle — match by description (Vehicle #) + company
        # This is the KEY FIX: no longer matching by serial number
        # ------------------------------------------------------------------
        vehicle = Vehicle.where("LOWER(description) = ?", vehicle_name.downcase)
                         .where(location_id: location.id).first
        vehicle ||= Vehicle.where("LOWER(description) = ?", vehicle_name.downcase).first

        unless vehicle
          vehicle = Vehicle.new(
            description: vehicle_name,
            code: vehicle_serial.presence || vehicle_name.parameterize,
            model_number: vehicle_model,
            location_id: location.id,
            engine_config_id: engine_config.id
          )
          vehicle.save!(validate: false)
        end

        # Update vehicle's engine config if it was wrong
        if vehicle.engine_config_id != engine_config.id
          vehicle.update_columns(engine_config_id: engine_config.id)
        end

        # Update vehicle's location if needed
        if vehicle.location_id != location.id
          vehicle.update_columns(location_id: location.id)
        end

        # ------------------------------------------------------------------
        # Parse emission values — handle "Not measured" and "Single Stack"
        # ------------------------------------------------------------------
        left_co2  = safe_float(row['Left-CO2%'])
        left_co   = safe_float(row['Left-CO'])
        left_nox  = safe_float(row['Left-NOx'])

        # Right bank: nil if "Single Stack" or "Not measured"
        right_co2 = is_single_stack ? nil : safe_float(row['Right-CO2%'])
        right_co  = is_single_stack ? nil : safe_float(row['Right-CO'])
        right_nox = is_single_stack ? nil : safe_float(row['Right-NOX'])

        # ------------------------------------------------------------------
        # Test Date
        # ------------------------------------------------------------------
        test_date = begin
          Date.strptime(row['Test Date'].to_s.strip, '%m/%d/%Y')
        rescue
          nil
        end
        next unless test_date

        # ------------------------------------------------------------------
        # Parse other numeric fields — handle "Not measured"
        # ------------------------------------------------------------------
        engine_hours   = safe_float(row['Engine Hours'])
        engine_rpm     = safe_float(row['Engine RPM'])
        alternator_rpm = safe_float(row['Alternator RPM'])
        engine_hp      = safe_float(row['Engine HP'])
        alternator_hp  = safe_float(row['Alternator HP'])

        # ------------------------------------------------------------------
        # Create Input — use vehicle + date + engine_hours for uniqueness
        # (allows multiple tests per vehicle per day)
        # ------------------------------------------------------------------
        input = Input.find_or_initialize_by(
          vehicle_id: vehicle.id,
          submitted: test_date.to_datetime,
          engine_hours: engine_hours
        )

        if input.persisted?
          skip_count += 1
          next
        end

        input.submitter_first_name   = 'Import'
        input.submitter_last_name    = 'User'
        input.submitter_email        = 'imports@ebmpros.com'
        input.company_code           = company.code
        input.location_code          = location.code
        input.vehicle_code           = vehicle.code
        input.location               = location
        input.user                   = import_user
        input.engine_hours           = engine_hours
        input.engine_rpm             = engine_rpm
        input.alternator_rpm         = alternator_rpm
        input.engine_hp              = engine_hp
        input.alternator_hp          = alternator_hp
        input.left_bank_co2_percent  = left_co2
        input.left_bank_co           = left_co
        input.left_bank_nox          = left_nox
        input.right_bank_co2_percent = right_co2
        input.right_bank_co          = right_co
        input.right_bank_nox         = right_nox
        input.has_engine_codes       = false
        input.auto_generated         = true
        input.test_type              = test_method.presence || 'manual'
        input.save!(validate: false)

        begin
          Output.process_input(input)
        rescue => e
          # Don't fail the import if output processing has issues
        end

        success_count += 1

      rescue => e
        error_count += 1
        errors << "Row #{$.}: #{e.message}"
      end
    end

    puts "\n=== Import Complete ==="
    puts "Imported: #{success_count}"
    puts "Skipped:  #{skip_count} (already in database)"
    puts "Errors:   #{error_count}" if error_count > 0
    errors.first(20).each { |e| puts "  - #{e}" } if errors.any?
  end
end

def safe_float(val)
  return nil if val.nil?
  str = val.to_s.strip
  return nil if str.blank? || str == 'Not measured' || str == 'Single Stack' || str == 'N/A'
  Float(str)
rescue
  nil
end


    CSV.foreach(file_path, headers: true, encoding: 'bom|utf-8') do |row|
      begin
        company_name = row['Company'].to_s.strip
        company = Company.find_or_initialize_by(code: company_name.parameterize)
        company.description ||= company_name
        company.save(validate: false)

        location_name = row['Location'].to_s.strip
        location = Location.find_or_initialize_by(code: location_name.parameterize, company_id: company.id)
        location.description ||= location_name
        location.attainment  ||= false
        location.save(validate: false)

        engine_make = row['Engine Make'].to_s.strip
        manufacturer = Manufacturer.find_or_initialize_by(code: engine_make.upcase)
        manufacturer.description ||= engine_make
        manufacturer.save(validate: false)

        engine_model = row['Engine Model'].to_s.strip
        engine = Engine.find_or_initialize_by(code: engine_model, manufacturer: manufacturer)
        engine.description ||= engine_model
        engine.drive_type  ||= default_drive_type
        engine.save(validate: false)

        engine_config = EngineConfig.find_or_initialize_by(engine: engine, code: engine_model)
        engine_config.rated_rpm      ||= row['Engine RPM'].to_f
        engine_config.rated_hp       ||= row['Engine HP'].to_f
        engine_config.is_real_values ||= false
        engine_config.save(validate: false)

        vehicle_serial = row['Vehicle Serial #'].to_s.strip
        vehicle = Vehicle.find_or_initialize_by(folder_code: vehicle_serial)
        vehicle.description   ||= row['Vehicle #'].to_s.strip
        vehicle.model_number  ||= row['Vehicle Model'].to_s.strip
        vehicle.location      ||= location
        vehicle.engine_config ||= engine_config
        vehicle.save(validate: false)

        test_date = begin
          Date.strptime(row['Test Date'].to_s.strip, '%m/%d/%Y')
        rescue
          Date.today
        end

        input = Input.find_or_initialize_by(vehicle: vehicle, submitted: test_date.to_datetime)

        if input.persisted?
          skip_count += 1
          next
        end

        input.submitter_first_name   = 'Import'
        input.submitter_last_name    = 'User'
        input.submitter_email        = 'imports@ebmpros.com'
        input.company_code           = company.code
        input.location_code          = location.code
        input.vehicle_code           = vehicle_serial
        input.location               = location
        input.user                   = import_user
        input.engine_hours           = row['Engine Hours'].to_f
        input.engine_rpm             = row['Engine RPM'].to_f
        input.alternator_rpm         = row['Alternator RPM'].to_f
        input.engine_hp              = row['Engine HP'].to_f
        input.alternator_hp          = row['Alternator HP'].to_f
        input.left_bank_co2_percent  = row['Left-CO2%'].to_f
        input.left_bank_co           = row['Left-CO'].to_f
        input.left_bank_nox          = row['Left-NOx'].to_f
        input.right_bank_co2_percent = row['Right-CO2%'].to_f
        input.right_bank_co          = row['Right-CO'].to_f
        input.right_bank_nox         = row['Right-NOX'].to_f
        input.has_engine_codes       = false
        input.auto_generated         = true
        input.test_type              = 'manual'
        input.save(validate: false)

        begin
          Output.process_input(input)
        rescue => e
          errors << "Output error row #{$.}: #{e.message}"
        end

        success_count += 1

      rescue => e
        error_count += 1
        errors << "Row #{$.}: #{e.message}"
      end
    end

    puts "\n=== Import Complete ==="
    puts "Imported: #{success_count}"
    puts "Skipped:  #{skip_count} (already in database)"
    puts "Errors:   #{error_count}" if error_count > 0
    errors.first(10).each { |e| puts "  - #{e}" } if errors.any?
  end
end
