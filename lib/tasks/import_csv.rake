require 'csv'
namespace :import do
  desc "Import historical emission test data from CSV"
  task :emission_tests, [:file] => :environment do |t, args|
    file_path = args[:file] || Rails.root.join('tmp', 'import', 'Data_dump_csv.csv')
    unless File.exist?(file_path)
      puts "ERROR: File not found at #{file_path}"
      exit 1
    end
    puts "Starting import from #{file_path}..."
    import_user = User.find_by(role: 'imports') || User.find_by(role: 'site_admin')
    default_drive_type = DriveType.first || DriveType.create!(code: 'ELECTRIC', description: 'Electric')
    success_count = 0
    error_count   = 0
    errors        = []
    CSV.foreach(file_path, headers: true, encoding: 'bom|utf-8') do |row|
      begin
        company_name = row['Company'].to_s.strip
        company = Company.find_or_create_by!(code: company_name.parameterize) do |c|
          c.description = company_name
        end
        location_name = row['Location'].to_s.strip
        location = Location.find_or_create_by!(code: location_name.parameterize, company: company) do |l|
          l.description = location_name
          l.attainment  = false
        end
        engine_make = row['Engine Make'].to_s.strip
        manufacturer = Manufacturer.find_or_create_by!(code: engine_make.upcase) do |m|
          m.description = engine_make
        end
        engine_model = row['Engine Model'].to_s.strip
        engine = Engine.find_or_initialize_by(code: engine_model, manufacturer: manufacturer)
        engine.description   ||= engine_model
        engine.drive_type    ||= default_drive_type
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
        input = Input.new(
          submitter_first_name:   'Import',
          submitter_last_name:    'User',
          submitter_email:        'imports@ebmpros.com',
          submitted:              test_date.to_datetime,
          company_code:           company.code,
          location_code:          location.code,
          vehicle_code:           vehicle_serial,
          location:               location,
          vehicle:                vehicle,
          user:                   import_user,
          engine_hours:           row['Engine Hours'].to_f,
          engine_rpm:             row['Engine RPM'].to_f,
          alternator_rpm:         row['Alternator RPM'].to_f,
          engine_hp:              row['Engine HP'].to_f,
          alternator_hp:          row['Alternator HP'].to_f,
          left_bank_co2_percent:  row['Left-CO2%'].to_f,
          left_bank_co:           row['Left-CO'].to_f,
          left_bank_nox:          row['Left-NOx'].to_f,
          right_bank_co2_percent: row['Right-CO2%'].to_f,
          right_bank_co:          row['Right-CO'].to_f,
          right_bank_nox:         row['Right-NOX'].to_f,
          has_engine_codes:       false,
          auto_generated:         true
        )
        input.save(validate: false)
        begin
          Output.process_input(input)
        rescue => e
          errors << "Output error row #{$.}: #{e.message}"
        end
        success_count += 1
        print '.' if success_count % 50 == 0
      rescue => e
        error_count += 1
        errors << "Row #{$.}: #{e.message}"
      end
    end
    puts "\n\n=== Import Complete ==="
    puts "Imported: #{success_count}"
    puts "Errors:   #{error_count}"
    errors.first(10).each { |e| puts "  - #{e}" } if errors.any?
  end
end
