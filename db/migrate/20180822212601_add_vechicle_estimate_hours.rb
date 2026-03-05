class AddVechicleEstimateHours < ActiveRecord::Migration[5.0]
  def change
    add_column :vehicles, :estimated_annual_vehicle_hours, :decimal, precision: 12, scale: 4
  end
end
