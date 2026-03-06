# ─── Redmond HT4 — Caterpillar C27 Seed (updated from app screenshot) ────────
#
# Engine config values sourced from live app Engine Configs screen:
#   CO2%: 7.3  |  CO: 115  |  NOx: 582  |  CO2+O2%: 18.3
#   Rated RPM: 1800  |  Rated HP: 783
#   Test Load%: 90  |  Test RPM: 1750  |  Test Boost PSI: 23
#   Test Fuel GPH: 30

puts "Seeding Redmond HT4 / Caterpillar C27 (updated)..."

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

# ── Engine Config — exact values from app screenshot ─────────────────────────
engine_config = EngineConfig.find_or_initialize_by(code: 'C27-Mode 1')
engine_config.description                = 'Caterpillar C27'
engine_config.engine                     = engine
engine_config.co2_percent                = 7.3
engine_config.co                         = 115.0
engine_config.nox                        = 582.0
engine_config.co2_plus_o2_percent        = 18.3    # CO2 + O2% combined check
engine_config.rated_rpm                  = 1800.0
engine_config.rated_hp                   = 783.0
engine_config.is_real_values             = true
# Telematically-Enabled Values
engine_config.test_percent_load          = 90.0    # ISO 8178 threshold
engine_config.test_rpm                   = 1750.0  # ISO 8178 RPM threshold
engine_config.test_boost_psi             = 23.0    # Boost at test conditions
engine_config.test_fuel_gallons_per_hour = 30.0    # Fuel consumption at test load
engine_config.save!(validate: false)
puts "  EngineConfig: #{engine_config.code} — load:#{engine_config.test_percent_load}% rpm:#{engine_config.test_rpm}"

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

# ── Telematics Config — thresholds pulled from engine_config ─────────────────
tc = TelematicsConfig.find_or_initialize_by(vehicle: vehicle, location: location)
tc.min_load_percent          = engine_config.test_percent_load  # 90%
tc.min_rpm                   = engine_config.test_rpm           # 1750
tc.consistency_threshold_pct = 15.0
tc.test_frequency_hours      = 4.0
tc.daily_report_hour         = 23
tc.sample_count              = 3
tc.sample_interval_seconds   = 10
tc.enabled                   = true
tc.notes                     = 'Redmond HT4 / Cat C27 — thresholds from engine config'
tc.save!(validate: false)

# ── Default Column Import Config ──────────────────────────────────────────────
# Pre-built from CSV analysis:
#   100% present: rpm, coolant_temperature, right/left exhaust temps, system_voltage,
#                 oil_pressure_psi, boost_psi, filter_oil_pressure, intake/fuel temp,
#                 lifetime_fuel/hours/idle, nox_ppm, o2_percent, oil_temp/condition,
#                 fuel_level_percent, fuel_gallons, truck_miles_traveled
#   88-94% present: percent_load, fuel_gallons_per_hour, co2_percent
#   56% present:  truck_payload_tons
#   0% present:   co, hydrocarbons, heater_voltage/current, smoke_setting
#                 + all summary columns (Load, LoadCnt, etc.)

default_map = {
  # ── Required for ISO 8178 detection ──
  "percent_load"              => { enabled: true,  db_column: "percent_load",              category: "iso8178",    notes: "94% present" },
  "rpm"                       => { enabled: true,  db_column: "rpm",                       category: "iso8178",    notes: "100% present" },

  # ── Required for EBM algorithm ──
  "nox_ppm"                   => { enabled: true,  db_column: "nox_ppm",                   category: "emissions",  notes: "100% present" },
  "co2_percent"               => { enabled: true,  db_column: "co2_percent",               category: "emissions",  notes: "88% present" },
  "o2_percent"                => { enabled: true,  db_column: "o2_percent",                category: "emissions",  notes: "100% present" },
  "co"                        => { enabled: false, db_column: "co",                        category: "emissions",  notes: "0% — not captured via telematics" },

  # ── Engine health ──
  "coolant_temperature"       => { enabled: true,  db_column: "coolant_temperature",       category: "engine",     notes: "100% present" },
  "right_exhaust_temperature" => { enabled: true,  db_column: "right_exhaust_temperature", category: "engine",     notes: "100% present" },
  "left_exhaust_temperature"  => { enabled: true,  db_column: "left_exhaust_temperature",  category: "engine",     notes: "100% present" },
  "oil_pressure_psi"          => { enabled: true,  db_column: "oil_pressure_psi",          category: "engine",     notes: "100% present" },
  "boost_psi"                 => { enabled: true,  db_column: "boost_psi",                 category: "engine",     notes: "100% present" },
  "filter_oil_pressure"       => { enabled: true,  db_column: "filter_oil_pressure",       category: "engine",     notes: "100% present — new field" },
  "oil_temperature"           => { enabled: true,  db_column: "oil_temperature",           category: "engine",     notes: "100% present" },
  "oil_condition"             => { enabled: true,  db_column: "oil_condition",             category: "engine",     notes: "100% present — new field" },
  "intake_air_temperature"    => { enabled: true,  db_column: "intake_air_temperature",    category: "engine",     notes: "100% present" },
  "throttle_position"         => { enabled: true,  db_column: "throttle_position",         category: "engine",     notes: "69% present" },
  "system_voltage"            => { enabled: true,  db_column: "system_voltage",            category: "engine",     notes: "100% present" },

  # ── Fuel & consumption ──
  "fuel_gallons_per_hour"     => { enabled: true,  db_column: "fuel_gallons_per_hour",     category: "fuel",       notes: "88% present" },
  "fuel_temperature"          => { enabled: true,  db_column: "fuel_temperature",          category: "fuel",       notes: "100% present" },
  "fuel_level_percent"        => { enabled: true,  db_column: "fuel_level_percent",        category: "fuel",       notes: "100% present" },
  "fuel_gallons"              => { enabled: true,  db_column: "fuel_gallons",              category: "fuel",       notes: "100% present" },
  "lifetime_fuel_consumption" => { enabled: true,  db_column: "lifetime_fuel_consumption", category: "fuel",       notes: "100% present" },
  "fuel_rate"                 => { enabled: true,  db_column: "fuel_rate",                 category: "fuel",       notes: "100% present — new field" },

  # ── Lifetime / operational ──
  "lifetime_operating_hours"  => { enabled: true,  db_column: "lifetime_operating_hours",  category: "operational", notes: "100% present" },
  "lifetime_idle_hours"       => { enabled: true,  db_column: "lifetime_idle_hours",       category: "operational", notes: "100% present — new field" },
  "lifetime_idle_fuel"        => { enabled: true,  db_column: "lifetime_idle_fuel",        category: "operational", notes: "100% present — new field" },

  # ── Payload / productivity ──
  "truck_payload_tons"        => { enabled: true,  db_column: "truck_payload_tons",        category: "payload",    notes: "56% present" },
  "truck_miles_traveled"      => { enabled: true,  db_column: "truck_miles_traveled",      category: "payload",    notes: "100% present" },

  # ── Sparse / future use ──
  "hydrocarbons"              => { enabled: false, db_column: "hydrocarbons",              category: "sparse",     notes: "0% — not captured in this dataset" },
  "heater_voltage"            => { enabled: false, db_column: "heater_voltage",            category: "sparse",     notes: "0% — not captured in this dataset" },
  "heater_current"            => { enabled: false, db_column: "heater_current",            category: "sparse",     notes: "0% — not captured in this dataset" },
  "smoke_setting"             => { enabled: false, db_column: "smoke_setting",             category: "sparse",     notes: "0% — not captured in this dataset" },

  # ── Summary rows — skip entirely ──
  "Load"          => { enabled: false, db_column: nil, category: "summary", notes: "Summary row — not per-reading data" },
  "LoadCnt"       => { enabled: false, db_column: nil, category: "summary", notes: "Summary row" },
  "Fueling"       => { enabled: false, db_column: nil, category: "summary", notes: "Summary row" },
  "Max"           => { enabled: false, db_column: nil, category: "summary", notes: "Summary row" },
  "Min"           => { enabled: false, db_column: nil, category: "summary", notes: "Summary row" },
  "Gal"           => { enabled: false, db_column: nil, category: "summary", notes: "Summary row" },
  "Truck Hrs"     => { enabled: false, db_column: nil, category: "summary", notes: "Summary row" },
  "Idle Hrs"      => { enabled: false, db_column: nil, category: "summary", notes: "Summary row" },
  "Run Hrs"       => { enabled: false, db_column: nil, category: "summary", notes: "Summary row" },
  "Idle%"         => { enabled: false, db_column: nil, category: "summary", notes: "Summary row" },
  "Miles"         => { enabled: false, db_column: nil, category: "summary", notes: "Summary row" },
  "Run Miles"     => { enabled: false, db_column: nil, category: "summary", notes: "Summary row" },
  "Tons"          => { enabled: false, db_column: nil, category: "summary", notes: "Summary row" },
  "Loads"         => { enabled: false, db_column: nil, category: "summary", notes: "Summary row" },
  "TMG"           => { enabled: false, db_column: nil, category: "summary", notes: "Summary row" },
}

col_config = TelematicsImportColumn.find_or_initialize_by(vehicle: vehicle, location: location)
col_config.column_map  = default_map
col_config.updated_by  = 'system/seed'
col_config.save!(validate: false)
puts "  ImportColumns: #{default_map.count { |_, v| v[:enabled] }} enabled / #{default_map.count { |_, v| !v[:enabled] }} disabled"

imports_user = User.find_or_initialize_by(email: 'telematics@ebmpros.com')
if imports_user.new_record?
  imports_user.password = imports_user.password_confirmation = SecureRandom.hex(16)
end
imports_user.assign_attributes(first_name: 'Telematics', last_name: 'System',
                                role: 'imports', is_active: true, location: location)
imports_user.save!(validate: false)

puts "\nRedmond HT4 seed complete!"
puts "  Engine config: #{engine_config.code} | load:#{tc.min_load_percent}% rpm:#{tc.min_rpm}"
puts "  Columns enabled: #{default_map.count { |_, v| v[:enabled] }}"
