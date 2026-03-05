class RenameCo2Percentage < ActiveRecord::Migration[5.0]
  def change
    rename_column :inputs, :left_bank_co2_percentage, :left_bank_co2_percent
    rename_column :inputs, :right_bank_co2_percentage, :right_bank_co2_percent
  end
end
