class CreateTelematicsImportColumns < ActiveRecord::Migration[7.1]
  def change
    create_table :telematics_configs do |t|
      t.integer  :vehicle_id,                  null: true
      t.integer  :location_id,                 null: false
      t.decimal  :min_load_percent,            precision: 8, scale: 2, default: 70.0,  null: false
      t.decimal  :min_rpm,                     precision: 8, scale: 2, default: 1400.0, null: false
      t.decimal  :consistency_threshold_pct,   precision: 8, scale: 2, default: 15.0,  null: false
      t.decimal  :test_frequency_hours,        precision: 6, scale: 2, default: 4.0,   null: false
      t.integer  :daily_report_hour,           default: 23,  null: false
      t.integer  :sample_count,                default: 3,   null: false
      t.integer  :sample_interval_seconds,     default: 10,  null: false
      t.boolean  :enabled,                     default: true, null: false
      t.string   :notes
      t.timestamps null: false
    end

    create_table :telematics_import_columns do |t|
      t.integer  :vehicle_id,   null: true
      t.integer  :location_id,  null: false
      t.json     :column_map,   null: false, default: {}
      t.string   :updated_by
      t.timestamps null: false
    end

    add_index :telematics_configs,         :vehicle_id
    add_index :telematics_configs,         :location_id
    add_index :telematics_import_columns,  :vehicle_id
    add_index :telematics_import_columns,  :location_id

    add_column :vehicle_stats, :filter_oil_pressure,  :decimal, precision: 10, scale: 4
    add_column :vehicle_stats, :fuel_rate,             :decimal, precision: 10, scale: 4
    add_column :vehicle_stats, :lifetime_idle_hours,   :decimal, precision: 12, scale: 2
    add_column :vehicle_stats, :lifetime_idle_fuel,    :decimal, precision: 12, scale: 4
    add_column :vehicle_stats, :oil_condition,         :decimal, precision: 8,  scale: 4
    add_column :vehicle_stats, :heater_voltage,        :decimal, precision: 8,  scale: 4
    add_column :vehicle_stats, :heater_current,        :decimal, precision: 8,  scale: 4
    add_column :vehicle_stats, :hydrocarbons,          :decimal, precision: 10, scale: 4
    add_column :vehicle_stats, :smoke_setting,         :decimal, precision: 8,  scale: 4
    add_column :vehicle_stats, :datetime,              :datetime
    add_column :vehicle_stats, :filename,              :string
  end
end
