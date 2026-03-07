class AddStatusToVehicles < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:vehicles, :last_diagnostic_status)
      add_column :vehicles, :last_diagnostic_status, :string
    end
    unless column_exists?(:vehicles, :last_test_date)
      add_column :vehicles, :last_test_date, :datetime
    end
  end
end
