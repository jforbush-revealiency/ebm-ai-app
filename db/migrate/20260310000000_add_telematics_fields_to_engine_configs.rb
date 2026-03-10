class AddTelematicsFieldsToEngineConfigs < ActiveRecord::Migration[7.0]
  def change
    add_column :engine_configs, :operating_rpm, :decimal, precision: 8, scale: 1
    add_column :engine_configs, :target_load, :decimal, precision: 5, scale: 1
  end
end
