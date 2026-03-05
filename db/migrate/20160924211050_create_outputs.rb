class CreateOutputs < ActiveRecord::Migration[5.0]
  def change
    create_table :outputs do |t|
      t.datetime :processed

      t.string :engine_alternator_rpm_code
      t.string :engine_alternator_rpm_message
      t.string :engine_alternator_hp_code
      t.string :engine_alternator_hp_message

      t.string :bank_balance_check_co2_percent_code
      t.string :bank_balance_check_co2_percent_message
      t.string :bank_balance_check_co_code
      t.string :bank_balance_check_co_message
      t.string :bank_balance_check_nox_code
      t.string :bank_balance_check_nox_message

      t.string :co2_percent_left_bank_code
      t.string :co2_percent_left_bank_message
      t.string :co2_percent_right_bank_code
      t.string :co2_percent_right_bank_message

      t.string :co_left_bank_code
      t.string :co_left_bank_message
      t.string :co_right_bank_code
      t.string :co_right_bank_message

      t.string :nox_left_bank_code
      t.string :nox_left_bank_message
      t.string :nox_right_bank_code
      t.string :nox_right_bank_message

      t.integer :input_id

      t.timestamps
    end

    add_index :outputs, :input_id
  end
end
