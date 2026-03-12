module Api
  class InputsController < BaseController
    def create
      input = Input.new(input_params)
      input.test_type = 'manual'
      input.auto_generated = false

      if input.save(validate: false)
        # Generate diagnostic output
        begin
          Output.process_input(input)
        rescue => e
          Rails.logger.error "Output processing error: #{e.message}"
        end

        # Update vehicle diagnostic status
        if input.vehicle
          status = DiagnosticService.calculate_status(input) rescue 'unknown'
          input.vehicle.update_columns(
            last_diagnostic_status: status,
            last_test_date: input.submitted
          )
        end

        render json: { id: input.id, vehicle_id: input.vehicle_id, message: "Test submitted successfully" }, status: :created
      else
        render json: { errors: input.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def input_params
      params.require(:input).permit(
        :vehicle_id, :vehicle_code, :company_code, :location_code,
        :submitted, :engine_hours, :engine_rpm, :engine_hp,
        :alternator_rpm, :alternator_hp,
        :left_bank_co2_percent, :left_bank_co, :left_bank_nox,
        :right_bank_co2_percent, :right_bank_co, :right_bank_nox,
        :has_engine_codes, :engine_codes_notes,
        :test_type, :submitter_first_name, :submitter_last_name,
        :submitter_email
      )
    end
  end
end
