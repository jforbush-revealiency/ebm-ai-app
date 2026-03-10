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
    errors        = []

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
        engin
