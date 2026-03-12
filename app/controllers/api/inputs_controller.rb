module Api
  class InputsController < BaseController
    def create
      extra_fields = {}
      extra_fields[:config_verified] = params[:input].delete(:config_verified)
      extra_fields[:engine_codes_notes] = params[:input].delete(:engine_codes_notes)
      input = Input.new(input_params)
      input.test_type = 'manual'
      input.auto_generated = false
      if input.save(validate: false)
        if input.vehicle
          status = DiagnosticService.calculate_status(input) rescue 'unknown'
          test_count = input.vehicle.inputs.count
          input.vehicle.update_columns(
            last_diagnostic_status: status,
            last_test_date: input.submitted,
            emission_test_count: test_count
          )
        end
        render json: {
          id: input.id,
          vehicle_id: input.vehicle_id,
          message: "Test submitted successfully"
        }, status: :created
      else
        render json: { errors: input.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      input = Input.find(params[:id])
      vehicle = input.vehicle

      # Delete associated outputs first
      Output.where(input_id: input.id).delete_all
      input.destroy!

      # Recalculate vehicle status after deletion
      if vehicle
        latest = vehicle.inputs.order(id: :desc).first
        if latest
          status = DiagnosticService.calculate_status(latest) rescue 'unknown'
          vehicle.update_columns(
            last_diagnostic_status: status,
            last_test_date: latest.submitted,
            emission_test_count: vehicle.inputs.count
          )
        else
          vehicle.update_columns(
            last_diagnostic_status: nil,
            last_test_date: nil,
            emission_test_count: 0
          )
        end
      end

      render json: { message: "Test deleted successfully" }
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Input not found" }, status: :not_found
    end

    private

    def input_params
      params.require(:input).permit(
        :vehicle_id, :vehicle_code, :company_code, :location_code,
        :submitted, :engine_hours, :engine_rpm, :engine_hp,
        :alternator_rpm, :alternator_hp,
        :left_bank_co2_percent, :left_bank_co, :left_bank_nox,
        :right_bank_co2_percent, :right_bank_co, :right_bank_nox,
        :has_engine_codes, :test_type,
        :submitter_first_name, :submitter_last_name, :submitter_email
      )
    end
  end
end
