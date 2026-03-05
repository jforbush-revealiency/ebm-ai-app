class AddIsRealValuesEngineConfig < ActiveRecord::Migration[5.0]
  def change
    add_column :engine_configs, :is_real_values, :boolean
  end
end
