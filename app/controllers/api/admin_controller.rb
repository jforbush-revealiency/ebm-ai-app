class Api::AdminController < ApplicationController
  # TEMPORARY - delete after use
  def reprocess_outputs
    updated = Input.where(auto_generated: true).update_all(test_type: 'manual')

    success = 0
    errors  = []

    Input.where(auto_generated: true).find_each do |input|
      begin
        Output.where(input: input).destroy_all
        Output.process_input(input)
        success += 1
      rescue => e
        errors << "Input #{input.id}: #{e.message}"
      end
    end

    render json: {
      message:     "Reprocess complete",
      updated:     updated,
      reprocessed: success,
      errors:      errors.first(20)
    }
  end
end
