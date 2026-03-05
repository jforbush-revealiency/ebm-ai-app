class CreateInputs < ActiveRecord::Migration[5.0]
  def change
    create_table :inputs do |t|
      t.string :submitter_first_name
      t.string :submitter_last_name
      t.string :submitter_email
      t.datetime :submitted

      t.string :company_code
      t.string :location_code
      t.string :vehicle_code
      t.boolean :has_engine_codes, default: 0, null: false
      t.decimal :engine_hours

      t.decimal :engine_rpm
      t.decimal :alternator_rpm
      t.decimal :engine_hp
      t.decimal :alternator_hp

      t.decimal :left_bank_co2_percentage
      t.decimal :left_bank_co
      t.decimal :left_bank_nox

      t.decimal :right_bank_co2_percentage
      t.decimal :right_bank_co
      t.decimal :right_bank_nox

      t.integer :location_id
      t.integer :vehicle_id
      t.integer :user_id
      t.integer :output_id

      t.timestamps
    end

    add_index :inputs, :location_id
    add_index :inputs, :vehicle_id
    add_index :inputs, :user_id
    add_index :inputs, :output_id
  end
end
