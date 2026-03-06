class CreateTelematicsImportColumns < ActiveRecord::Migration[7.1]
  def change
    create_table :telematics_import_columns do |t|
      # Scope — null vehicle_id means applies to all vehicles at this location
      t.integer  :vehicle_id,   null: true
      t.integer  :location_id,  null: false

      # JSON column map: { "csv_column_name" => { enabled: true, db_column: "vehicle_stats_column" } }
      t.json     :column_map,   null: false, default: {}

      t.string   :updated_by    # email of admin who last changed this
      t.timestamps null: false
    end

    add_index :telematics_import_columns, :vehicle_id
    add_index :telematics_import_columns, :location_id

    # ── Add new columns to vehicle_stats ────────────────────────────────────
    # These are in the Monico CSV but not in the existing schema.
    # Stored for future analysis even if not used in current EBM algorithm.
    add_column :vehicle_stats, :filter_oil_pressure,      :decimal, precision: 10, scale: 4
    add_column :vehicle_stats, :fuel_rate,                :decimal, precision: 10, scale: 4
    add_column :vehicle_stats, :lifetime_idle_hours,      :decimal, precision: 12, scale: 2
    add_column :vehicle_stats, :lifetime_idle_fuel,       :decimal, precision: 12, scale: 4
    add_column :vehicle_stats, :oil_condition,            :decimal, precision: 8,  scale: 4
    add_column :vehicle_stats, :heater_voltage,           :decimal, precision: 8,  scale: 4
    add_column :vehicle_stats, :heater_current,           :decimal, precision: 8,  scale: 4
    add_column :vehicle_stats, :hydrocarbons,             :decimal, precision: 10, scale: 4
    add_column :vehicle_stats, :smoke_setting,            :decimal, precision: 8,  scale: 4
    add_column :vehicle_stats, :datetime,                 :datetime   # parsed date+time combined
    add_column :vehicle_stats, :filename,                 :string
  end
end
