# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 20181025160239) do

  create_table "companies", force: :cascade do |t|
    t.string   "code"
    t.string   "description"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.decimal  "average_diesel_fuel", precision: 12, scale: 4
  end

  create_table "drive_types", force: :cascade do |t|
    t.string   "code"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "engine_configs", force: :cascade do |t|
    t.string   "code"
    t.string   "description"
    t.decimal  "co2_percent",                precision: 10, scale: 4
    t.decimal  "co",                         precision: 10, scale: 4
    t.decimal  "nox",                        precision: 10, scale: 4
    t.integer  "engine_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "is_real_values"
    t.decimal  "co2_plus_o2_percent",        precision: 12, scale: 4
    t.decimal  "test_percent_load",          precision: 12, scale: 4
    t.decimal  "test_rpm",                   precision: 12, scale: 4
    t.decimal  "test_boost_psi",             precision: 12, scale: 4
    t.decimal  "test_fuel_gallons_per_hour", precision: 12, scale: 4
    t.decimal  "rated_rpm",                  precision: 12, scale: 4
    t.decimal  "rated_hp",                   precision: 12, scale: 4
    t.index ["engine_id"], name: "index_engine_configs_on_engine_id"
  end

  create_table "engines", force: :cascade do |t|
    t.string   "code"
    t.string   "description"
    t.integer  "manufacturer_id"
    t.integer  "drive_type_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "is_single_stack", default: false, null: false
    t.index ["drive_type_id"], name: "index_engines_on_drive_type_id"
    t.index ["manufacturer_id"], name: "index_engines_on_manufacturer_id"
  end

  create_table "inputs", force: :cascade do |t|
    t.string   "submitter_first_name"
    t.string   "submitter_last_name"
    t.string   "submitter_email"
    t.datetime "submitted"
    t.string   "company_code"
    t.string   "location_code"
    t.string   "vehicle_code"
    t.boolean  "has_engine_codes",                                       default: false, null: false
    t.decimal  "engine_hours",                  precision: 10, scale: 4
    t.decimal  "engine_rpm",                    precision: 10, scale: 4
    t.decimal  "alternator_rpm",                precision: 10, scale: 4
    t.decimal  "engine_hp",                     precision: 10, scale: 4
    t.decimal  "alternator_hp",                 precision: 10, scale: 4
    t.decimal  "left_bank_co2_percent",         precision: 10, scale: 4
    t.decimal  "left_bank_co",                  precision: 10, scale: 4
    t.decimal  "left_bank_nox",                 precision: 10, scale: 4
    t.decimal  "right_bank_co2_percent",        precision: 10, scale: 4
    t.decimal  "right_bank_co",                 precision: 10, scale: 4
    t.decimal  "right_bank_nox",                precision: 10, scale: 4
    t.integer  "location_id"
    t.integer  "vehicle_id"
    t.integer  "user_id"
    t.integer  "output_id"
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.string   "updated_by_first_name"
    t.string   "updated_by_last_name"
    t.string   "updated_by_email"
    t.string   "has_latest_configuration_file"
    t.boolean  "auto_generated",                                         default: false, null: false
    t.index ["location_id"], name: "index_inputs_on_location_id"
    t.index ["output_id"], name: "index_inputs_on_output_id"
    t.index ["user_id"], name: "index_inputs_on_user_id"
    t.index ["vehicle_id"], name: "index_inputs_on_vehicle_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string   "code"
    t.string   "description"
    t.boolean  "attainment"
    t.integer  "company_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["company_id"], name: "index_locations_on_company_id"
  end

  create_table "manufacturers", force: :cascade do |t|
    t.string   "code"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "outputs", force: :cascade do |t|
    t.datetime "processed"
    t.string   "engine_alternator_rpm_code"
    t.string   "engine_alternator_rpm_message",          limit: 1000
    t.string   "engine_alternator_hp_code"
    t.string   "engine_alternator_hp_message",           limit: 1000
    t.string   "bank_balance_check_co2_percent_code"
    t.string   "bank_balance_check_co2_percent_message", limit: 1000
    t.string   "bank_balance_check_co_code"
    t.string   "bank_balance_check_co_message",          limit: 1000
    t.string   "bank_balance_check_nox_code"
    t.string   "bank_balance_check_nox_message",         limit: 1000
    t.string   "co2_percent_left_bank_code"
    t.string   "co2_percent_left_bank_message",          limit: 1000
    t.string   "co2_percent_right_bank_code"
    t.string   "co2_percent_right_bank_message",         limit: 1000
    t.string   "co_left_bank_code"
    t.string   "co_left_bank_message",                   limit: 1000
    t.string   "co_right_bank_code"
    t.string   "co_right_bank_message",                  limit: 1000
    t.string   "nox_left_bank_code"
    t.string   "nox_left_bank_message",                  limit: 1000
    t.string   "nox_right_bank_code"
    t.string   "nox_right_bank_message",                 limit: 1000
    t.integer  "input_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "engine_hours_code"
    t.string   "engine_hours_message",                   limit: 1000
    t.index ["input_id"], name: "index_outputs_on_input_id"
  end

  create_table "parameters", force: :cascade do |t|
    t.string   "code"
    t.string   "description"
    t.string   "value",          limit: 1000
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "parameter_type"
  end



  create_table "users", force: :cascade do |t|
    t.string   "email",                   default: "",    null: false
    t.string   "encrypted_password",      default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "is_active",               default: false, null: false
    t.boolean  "require_password_change", default: false, null: false
    t.integer  "location_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "role"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "valid_emission_tests", force: :cascade do |t|
    t.string   "code"
    t.datetime "datetime"
    t.string   "batch"
    t.date     "date"
    t.time     "time"
    t.integer  "percent_load"
    t.integer  "rpm"
    t.decimal  "boost_psi",             precision: 12, scale: 4
    t.decimal  "fuel_gallons_per_hour", precision: 12, scale: 4
    t.decimal  "nox_ppm",               precision: 12, scale: 4
    t.decimal  "co2_percent",           precision: 12, scale: 4
    t.integer  "vehicle_stat_id"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.index ["code"], name: "index_valid_emission_tests_on_code"
    t.index ["datetime"], name: "index_valid_emission_tests_on_datetime"
    t.index ["vehicle_stat_id"], name: "index_valid_emission_tests_on_vehicle_stat_id"
  end

  create_table "valid_emission_tests_bk", force: :cascade do |t|
    t.string   "code"
    t.datetime "datetime"
    t.string   "batch"
    t.date     "date"
    t.time     "time"
    t.integer  "percent_load"
    t.integer  "rpm"
    t.decimal  "boost_psi",             precision: 12, scale: 4
    t.decimal  "fuel_gallons_per_hour", precision: 12, scale: 4
    t.decimal  "nox_ppm",               precision: 12, scale: 4
    t.decimal  "co2_percent",           precision: 12, scale: 4
    t.integer  "vehicle_stat_id"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.index ["code"], name: "index_valid_emission_tests_on_code"
    t.index ["datetime"], name: "index_valid_emission_tests_on_datetime"
    t.index ["vehicle_stat_id"], name: "index_valid_emission_tests_on_vehicle_stat_id"
  end

  create_table "vehicle_stat_import_logs", force: :cascade do |t|
    t.string   "code"
    t.string   "filename"
    t.string   "status"
    t.string   "log",        limit: 4000
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "vehicle_stats", force: :cascade do |t|
    t.string   "code"
    t.datetime "datetime"
    t.integer  "percent_load"
    t.integer  "rpm"
    t.integer  "coolant_temperature"
    t.integer  "right_exhaust_temperature"
    t.integer  "left_exhaust_temperature"
    t.decimal  "throttle_position",         precision: 12, scale: 4
    t.decimal  "system_voltage",            precision: 12, scale: 4
    t.decimal  "oil_pressure_psi",          precision: 12, scale: 4
    t.decimal  "boost_psi",                 precision: 12, scale: 4
    t.decimal  "intake_air_temperature",    precision: 12, scale: 4
    t.decimal  "fuel_temperature",          precision: 12, scale: 4
    t.decimal  "lifetime_fuel_consumption", precision: 12, scale: 4
    t.decimal  "lifetime_operating_hours",  precision: 12, scale: 4
    t.decimal  "lifetime_idle_hours",       precision: 12, scale: 4
    t.decimal  "lifetime_idle_fuel",        precision: 12, scale: 4
    t.decimal  "nox_ppm",                   precision: 12, scale: 4
    t.decimal  "o2_percent",                precision: 12, scale: 4
    t.decimal  "oil_temperature",           precision: 12, scale: 4
    t.decimal  "oil_condition",             precision: 12, scale: 4
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "filename"
    t.date     "date"
    t.time     "time"
    t.decimal  "filter_oil_pressure",       precision: 12, scale: 4
    t.decimal  "smoke_setting",             precision: 12, scale: 4
    t.decimal  "fuel_gallons_per_hour",     precision: 12, scale: 4
    t.decimal  "fuel_rate",                 precision: 12, scale: 4
    t.decimal  "co",                        precision: 12, scale: 4
    t.decimal  "hydrocarbons",              precision: 12, scale: 4
    t.decimal  "heater_voltage",            precision: 12, scale: 4
    t.decimal  "heater_current",            precision: 12, scale: 4
    t.decimal  "fuel_level_percent",        precision: 12, scale: 4
    t.decimal  "fuel_gallons",              precision: 12, scale: 4
    t.decimal  "truck_payload_tons",        precision: 12, scale: 4
    t.decimal  "truck_miles_traveled",      precision: 12, scale: 4
    t.index ["code"], name: "index_vehicle_stats_on_code"
    t.index ["date"], name: "index_vehicle_stats_on_date"
    t.index ["datetime"], name: "index_vehicle_stats_on_datetime"
    t.index ["filename"], name: "index_vehicle_stats_on_filename"
    t.index ["time"], name: "index_vehicle_stats_on_time"
  end

  create_table "vehicle_stats_bk", id: false, force: :cascade do |t|
    t.integer  "id",                                                 default: 0, null: false
    t.string   "code"
    t.datetime "datetime"
    t.integer  "percent_load"
    t.integer  "rpm"
    t.integer  "coolant_temperature"
    t.integer  "right_exhaust_temperature"
    t.integer  "left_exhaust_temperature"
    t.decimal  "throttle_position",         precision: 12, scale: 4
    t.decimal  "system_voltage",            precision: 12, scale: 4
    t.decimal  "oil_pressure_psi",          precision: 12, scale: 4
    t.decimal  "boost_psi",                 precision: 12, scale: 4
    t.decimal  "intake_air_temperature",    precision: 12, scale: 4
    t.decimal  "fuel_temperature",          precision: 12, scale: 4
    t.decimal  "lifetime_fuel_consumption", precision: 12, scale: 4
    t.decimal  "lifetime_operating_hours",  precision: 12, scale: 4
    t.decimal  "lifetime_idle_hours",       precision: 12, scale: 4
    t.decimal  "lifetime_idle_fuel",        precision: 12, scale: 4
    t.decimal  "nox_ppm",                   precision: 12, scale: 4
    t.decimal  "o2_percent",                precision: 12, scale: 4
    t.decimal  "oil_temperature",           precision: 12, scale: 4
    t.decimal  "oil_condition",             precision: 12, scale: 4
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.string   "filename"
    t.date     "date"
    t.time     "time"
    t.decimal  "filter_oil_pressure",       precision: 12, scale: 4
    t.decimal  "smoke_setting",             precision: 12, scale: 4
    t.decimal  "fuel_gallons_per_hour",     precision: 12, scale: 4
    t.decimal  "fuel_rate",                 precision: 12, scale: 4
    t.decimal  "co",                        precision: 12, scale: 4
    t.decimal  "hydrocarbons",              precision: 12, scale: 4
    t.decimal  "heater_voltage",            precision: 12, scale: 4
    t.decimal  "heater_current",            precision: 12, scale: 4
    t.decimal  "fuel_level_percent",        precision: 12, scale: 4
    t.decimal  "fuel_gallons",              precision: 12, scale: 4
    t.decimal  "truck_payload_tons",        precision: 12, scale: 4
    t.decimal  "truck_miles_traveled",      precision: 12, scale: 4
  end

  create_table "vehicles", force: :cascade do |t|
    t.string   "code"
    t.string   "description"
    t.string   "model_number"
    t.string   "serial_number"
    t.integer  "engine_config_id"
    t.integer  "location_id"
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.string   "folder_code"
    t.boolean  "telematic",                                               default: false, null: false
    t.decimal  "estimated_annual_vehicle_hours", precision: 12, scale: 4
    t.index ["engine_config_id"], name: "index_vehicles_on_engine_config_id"
    t.index ["location_id"], name: "index_vehicles_on_location_id"
  end

end
