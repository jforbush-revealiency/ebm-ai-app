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
        # Update vehicle diagnostic status and test count
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
```

Commit that, then paste this into Lovable to fix the test history display:
```
On the diagnostic report page, fix the Test History section:

1. Show ALL tests for the vehicle, not just the first 10. 
   Remove any limit/slice on the test history list.

2. Sort tests by date DESCENDING (newest first), so the 
   most recent test appears at the top of the list.

3. The "Viewing" indicator should be on the most recent 
   test by default (the one at the top of the sorted list).

Give me the COMPLETE replacement file.
