puts "Seeding Redmond HT4 / Caterpillar C27..."

company = Company.find_or_initialize_by(code: 'REDMOND')
company.description         = 'Redmond Mining Operations'
company.average_diesel_fuel = 3.80
company.save!(validate: false)

location = Location.find_or_initialize_by(code: 'REDMOND-SITE-1')
location.description = 'Redmond Open Pit — Site 1'
location.attainment  = false
location.company     = company
location.save!(validate: false)

cat = Manufacturer.find_or_initialize_by(code: 'CATERPILLAR')
cat.description = 'Caterpillar Inc.'
cat.save!(validate: false)

drive_type = DriveType.find_or_initialize_by(code: 'DIESEL-ELECTRIC')
drive_type.description = 'Diesel-Electric Drive'
drive_type.save!(validate: false)

engine = Engine.find_or_initialize_by(code: 'CAT-C27')
engine.description     = 'Caterpillar C27 — 12-Cylinder V-Type Diesel'
engine.manufacturer    = cat
engine.drive_type      = drive_type
engine.is_single_stack = true
engine.save!(validate: false)

engine_config = EngineConfig.find_or_initialize_by(code: 'C27-Mode 1')
engine_config.description                = 'Caterpillar C27'
engine_config.engine                     = engine
engine_config.co2_percent                = 7.3
engine_config.co                         = 115.0
engine_config.nox                        = 582.0
engine_config.rated_rpm                  = 1800.0
engine_config.rated_hp                   = 783.0
engine_config.is_real_values             = true
engine_config.test_percent_load          = 90.0
engine_config.test_rpm                   = 1750.0
engine_config.test_boost_psi             = 23.0
engine_config.test_fuel_gallons_per_hour = 30.0
engine_config.save!(validate: false)
puts "  EngineConfig: #{engine_config.code}"

vehicle = Vehicle.find_or_initialize_by(folder_code: 'redmond_ht4')
vehicle.code           = 'redmond_ht4'
vehicle.description    = 'Redmond Haul Truck 4'
vehicle.model_number   = 'CAT 793F'
vehicle.serial_number  = 'HT4-REDMOND'
vehicle.engine_config  = engine_config
vehicle.location       = location
vehicle.telematic      = true
vehicle.estimated_annual_vehicle_hours = 5000.0
vehicle.save!(validate: false)
puts "  Vehicle: #{vehicle.code}"

tc = TelematicsConfig.find_or_initialize_by(vehicle: vehicle, location: location)
tc.min_load_percent          = 90.0
tc.min_rpm                   = 1750.0
tc.consistency_threshold_pct = 15.0
tc.test_frequency_hours      = 4.0
tc.daily_report_hour         = 23
tc.sample_count              = 3
tc.sample_interval_seconds   = 10
tc.enabled                   = true
tc.notes                     = 'Redmond HT4 / Cat C27 — ISO 8178 config'
tc.save!(validate: false)
puts "  TelematicsConfig: load>=#{tc.min_load_percent}% rpm>=#{tc.min_rpm}"

default_map = {
  "percent_load"              => { "enabled" => true,  "db_column" => "percent_load",              "category" => "iso8178" },
  "rpm"                       => { "enabled" => true,  "db_column" => "rpm",                       "category" => "iso8178" },
  "nox_ppm"                   => { "enabled" => true,  "db_column" => "nox_ppm",                   "category" => "emissions" },
  "co2_percent"               => { "enabled" => true,  "db_column" => "co2_percent",               "category" => "emissions" },
  "o2_percent"                => { "enabled" => true,  "db_column" => "o2_percent",                "category" => "emissions" },
  "co"                        => { "enabled" => false, "db_column" => "co",                        "category" => "emissions" },
  "coolant_temperature"       => { "enabled" => true,  "db_column" => "coolant_temperature",       "category" => "engine" },
  "right_exhaust_temperature" => { "enabled" => true,  "db_column" => "right_exhaust_temperature", "category" => "engine" },
  "left_exhaust_temperature"  => { "enabled" => true,  "db_column" => "left_exhaust_temperature",  "category" => "engine" },
  "oil_pressure_psi"          => { "enabled" => true,  "db_column" => "oil_pressure_psi",          "category" => "engine" },
  "boost_psi"                 => { "enabled" => true,  "db_column" => "boost_psi",                 "category" => "engine" },
  "filter_oil_pressure"       => { "enabled" => true,  "db_column" => "filter_oil_pressure",       "category" => "engine" },
  "oil_temperature"           => { "enabled" => true,  "db_column" => "oil_temperature",           "category" => "engine" },
  "oil_condition"             => { "enabled" => true,  "db_column" => "oil_condition",             "category" => "engine" },
  "intake_air_temperature"    => { "enabled" => true,  "db_column" => "intake_air_temperature",    "category" => "engine" },
  "fuel_temperature"          => { "enabled" => true,  "db_column" => "fuel_temperature",          "category" => "engine" },
  "throttle_position"         => { "enabled" => true,  "db_column" => "throttle_position",         "category" => "engine" },
  "system_voltage"            => { "enabled" => true,  "db_column" => "system_voltage",            "category" => "engine" },
  "fuel_gallons_per_hour"     => { "enabled" => true,  "db_column" => "fuel_gallons_per_hour",     "category" => "fuel" },
  "fuel_level_percent"        => { "enabled" => true,  "db_column" => "fuel_level_percent",        "category" => "fuel" },
  "fuel_gallons"              => { "enabled" => true,  "db_column" => "fuel_gallons",              "category" => "fuel" },
  "lifetime_fuel_consumption" => { "enabled" => true,  "db_column" => "lifetime_fuel_consumption", "category" => "fuel" },
  "fuel_rate"                 => { "enabled" => true,  "db_column" => "fuel_rate",                 "category" => "fuel" },
  "lifetime_operating_hours"  => { "enabled" => true,  "db_column" => "lifetime_operating_hours",  "category" => "operational" },
  "lifetime_idle_hours"       => { "enabled" => true,  "db_column" => "lifetime_idle_hours",       "category" => "operational" },
  "lifetime_idle_fuel"        => { "enabled" => true,  "db_column" => "lifetime_idle_fuel",        "category" => "operational" },
  "truck_payload_tons"        => { "enabled" => true,  "db_column" => "truck_payload_tons",        "category" => "payload" },
  "truck_miles_traveled"      => { "enabled" => true,  "db_column" => "truck_miles_traveled",      "category" => "payload" },
  "hydrocarbons"              => { "enabled" => false, "db_column" => "hydrocarbons",              "category" => "sparse" },
  "heater_voltage"            => { "enabled" => false, "db_column" => "heater_voltage",            "category" => "sparse" },
  "heater_current"            => { "enabled" => false, "db_column" => "heater_current",            "category" => "sparse" },
  "smoke_setting"             => { "enabled" => false, "db_column" => "smoke_setting",             "category" => "sparse" },
}

col_config = TelematicsImportColumn.find_or_initialize_by(vehicle: vehicle, location: location)
col_config.column_map = default_map
col_config.updated_by = 'system/seed'
col_config.save!(validate: false)
puts "  ImportColumns: #{default_map.count { |_, v| v['enabled'] }} enabled"

imports_user = User.find_or_initialize_by(email: 'telematics@ebmpros.com')
if imports_user.new_record?
  imports_user.password = imports_user.password_confirmation = SecureRandom.hex(16)
end
imports_user.first_name = 'Telematics'
imports_user.last_name  = 'System'
imports_user.role       = 'imports'
imports_user.is_active  = true
imports_user.location   = location
imports_user.save!(validate: false)
puts "  Imports user: #{imports_user.email}"

puts "\nRedmond HT4 seed complete!"
