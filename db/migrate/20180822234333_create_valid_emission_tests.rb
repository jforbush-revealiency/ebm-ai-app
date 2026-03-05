class CreateValidEmissionTests < ActiveRecord::Migration[5.0]
  def change
    create_table :valid_emission_tests do |t|
      t.string :code
      t.datetime :datetime
      t.string :batch
      t.date :date
      t.time :time
      t.integer :percent_load
      t.integer :rpm
      t.decimal :boost_psi, precision: 12, scale: 4
      t.decimal :fuel_gallons_per_hour, precision: 12, scale: 4
      t.decimal :nox_ppm, precision: 12, scale: 4
      t.decimal :co2_percent, precision: 12, scale: 4
      t.integer :vehicle_stat_id

      t.timestamps
    end

    add_index :valid_emission_tests, :code
    add_index :valid_emission_tests, :datetime
    add_index :valid_emission_tests, :vehicle_stat_id
  end
end
