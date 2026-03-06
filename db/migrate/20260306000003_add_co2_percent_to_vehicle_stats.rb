class AddCo2PercentToVehicleStats < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:vehicle_stats, :co2_percent)
      add_column :vehicle_stats, :co2_percent, :decimal, precision: 10, scale: 4
    end
  end
end