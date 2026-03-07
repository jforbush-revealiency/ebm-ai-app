class Api::AdminController < Api::BaseController
  def reprocess_outputs
    limit = (params[:limit] || 50).to_i
    offset = (params[:offset] || 0).to_i

    inputs = Input.where(auto_generated: true).offset(offset).limit(limit)
    inputs.update_all(test_type: 'manual')

    success = 0
    errors = []

    inputs.each do |input|
      begin
        Output.where(input: input).destroy_all
        Output.process_input(input)
        success += 1
      rescue => e
        errors << "Input #{input.id}: #{e.message}"
      end
    end

    total = Input.where(auto_generated: true).count

    render json: {
      message: "Batch complete",
      offset: offset,
      limit: limit,
      reprocessed: success,
      total: total,
      next_offset: offset + limit,
      done: (offset + limit) >= total,
      errors: errors
    }
  end
end
