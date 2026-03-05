class ChangeDecimalsToPrecisions < ActiveRecord::Migration[5.0]
  def up
    change_column :engine_configs, :co2_percent, :decimal, precision: 10, scale: 4
    change_column :engine_configs, :co, :decimal, precision: 10, scale: 4
    change_column :engine_configs, :nox, :decimal, precision: 10, scale: 4

    change_column :inputs, :engine_hours, :decimal, precision: 10, scale: 4
    change_column :inputs, :engine_rpm, :decimal, precision: 10, scale: 4
    change_column :inputs, :alternator_rpm, :decimal, precision: 10, scale: 4
    change_column :inputs, :engine_hp, :decimal, precision: 10, scale: 4
    change_column :inputs, :alternator_hp, :decimal, precision: 10, scale: 4
    change_column :inputs, :left_bank_co2_percentage, :decimal, precision: 10, scale: 4
    change_column :inputs, :left_bank_co, :decimal, precision: 10, scale: 4
    change_column :inputs, :left_bank_nox, :decimal, precision: 10, scale: 4
    change_column :inputs, :right_bank_co2_percentage, :decimal, precision: 10, scale: 4
    change_column :inputs, :right_bank_co, :decimal, precision: 10, scale: 4
    change_column :inputs, :right_bank_nox, :decimal, precision: 10, scale: 4
  end

  def down
    change_column :engine_configs, :co2_percent, :decimal
    change_column :engine_configs, :co, :decimal
    change_column :engine_configs, :nox, :decimal

    change_column :inputs, :engine_hours, :decimal
    change_column :inputs, :engine_rpm, :decimal
    change_column :inputs, :alternator_rpm, :decimal
    change_column :inputs, :engine_hp, :decimal
    change_column :inputs, :alternator_hp, :decimal
    change_column :inputs, :left_bank_co2_percentage, :decimal
    change_column :inputs, :left_bank_co, :decimal
    change_column :inputs, :left_bank_nox, :decimal
    change_column :inputs, :right_bank_co2_percentage, :decimal
    change_column :inputs, :right_bank_co, :decimal
    change_column :inputs, :right_bank_nox, :decimal
  end
end
