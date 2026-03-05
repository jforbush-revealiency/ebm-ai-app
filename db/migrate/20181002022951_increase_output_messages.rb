class IncreaseOutputMessages < ActiveRecord::Migration[5.0]
  def up
    change_column :outputs, :engine_alternator_rpm_message, :string, limit: 1000
    change_column :outputs, :engine_alternator_hp_message, :string, limit: 1000
    change_column :outputs, :bank_balance_check_co2_percent_message, :string, limit: 1000
    change_column :outputs, :bank_balance_check_co_message, :string, limit: 1000
    change_column :outputs, :bank_balance_check_nox_message, :string, limit: 1000
    change_column :outputs, :co2_percent_left_bank_message, :string, limit: 1000
    change_column :outputs, :co2_percent_right_bank_message, :string, limit: 1000
    change_column :outputs, :nox_left_bank_message, :string, limit: 1000
    change_column :outputs, :nox_right_bank_message, :string, limit: 1000
    change_column :outputs, :engine_hours_message, :string, limit: 1000
  end

  def down
    change_column :outputs, :engine_alternator_rpm_message, :string, limit: 255
    change_column :outputs, :engine_alternator_hp_message, :string, limit: 255
    change_column :outputs, :bank_balance_check_co2_percent_message, :string, limit: 255
    change_column :outputs, :bank_balance_check_co_message, :string, limit: 255
    change_column :outputs, :bank_balance_check_nox_message, :string, limit: 255
    change_column :outputs, :co2_percent_left_bank_message, :string, limit: 255
    change_column :outputs, :co2_percent_right_bank_message, :string, limit: 255
    change_column :outputs, :nox_left_bank_message, :string, limit: 255
    change_column :outputs, :nox_right_bank_message, :string, limit: 255
    change_column :outputs, :engine_hours_message, :string, limit: 255
  end
end
