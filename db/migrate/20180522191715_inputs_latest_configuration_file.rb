class InputsLatestConfigurationFile < ActiveRecord::Migration[5.0]
  def change
    add_column :inputs, :has_latest_configuration_file, :string
  end
end
