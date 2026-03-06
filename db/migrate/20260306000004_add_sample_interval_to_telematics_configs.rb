class AddSampleIntervalToTelematicsConfigs < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:telematics_configs, :sample_interval_seconds)
      add_column :telematics_configs, :sample_interval_seconds, :integer, default: 10
    end
  end
end