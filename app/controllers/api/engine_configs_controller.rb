module Api
  class EngineConfigsController < BaseController
    def update
      config = EngineConfig.find(params[:id])
      allowed = params.require(:engine_config).permit(
        :engine, :co2_percent, :co, :nox, :rated_rpm, :rated_hp,
        :operating_rpm, :target_load
      )

      # Handle engine name separately — belongs_to :engine conflicts with the column
      if allowed.key?("engine")
        engine_name = allowed.delete("engine")
        config.update_columns(engine: engine_name)
      end

      if config.update(allowed)
        render json: config.as_json
      else
        render json: { errors: config.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
