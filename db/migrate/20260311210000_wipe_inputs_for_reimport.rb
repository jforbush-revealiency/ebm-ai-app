class WipeInputsForReimport < ActiveRecord::Migration[7.1]
  def up
    Rails.logger.info "=== Wiping all inputs and outputs for clean re-import ==="

    output_count = Output.count
    input_count = Input.count

    Output.delete_all
    Input.delete_all

    # Reset vehicle diagnostic statuses
    if Vehicle.column_names.include?('last_diagnostic_status')
      Vehicle.update_all(last_diagnostic_status: nil)
    end
    if Vehicle.column_names.include?('last_test_date')
      Vehicle.update_all(last_test_date: nil)
    end

    Rails.logger.info "Deleted #{output_count} outputs and #{input_count} inputs"
    Rails.logger.info "Reset all vehicle diagnostic statuses"
    Rails.logger.info "=== Ready for clean re-import ==="
  end

  def down
    Rails.logger.warn "Cannot undo data wipe"
  end
end
