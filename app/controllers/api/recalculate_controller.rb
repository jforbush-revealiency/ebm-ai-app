module Api
  class RecalculateController < BaseController
    def create
      updated = 0
      skipped = 0

      Vehicle.find_each do |vehicle|
        input = vehicle.inputs.order(id: :desc).first
        if input.nil?
          skipped += 1
          next
        end
        begin
          status = DiagnosticService.calculate_status(input)
          vehicle.update_columns(
            last_diagnostic_status: status,
            last_test_date: input.submitted
          )
          updated += 1
        rescue => e
          skipped += 1
        end
      end

      render json: {
        message: "Recalculation complete",
        updated: updated,
        skipped: skipped
      }
    end
  end
end
