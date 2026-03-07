class FixTelematicTestTypes < ActiveRecord::Migration[7.1]
  def up
    # Add the column if it doesn't exist
    unless column_exists?(:inputs, :test_type)
      add_column :inputs, :test_type, :string, default: 'manual'
    end

    # Set all auto-generated inputs to manual
    execute "UPDATE inputs SET test_type = 'manual' WHERE auto_generated = true"

    # Set Redmond HT4 telematic records back to telematic
    execute "UPDATE inputs SET test_type = 'telematic' WHERE vehicle_code IN (SELECT folder_code FROM vehicles WHERE LOWER(folder_code) LIKE 'testht%')"
  end

  def down
    remove_column :inputs, :test_type if column_exists?(:inputs, :test_type)
  end
end
