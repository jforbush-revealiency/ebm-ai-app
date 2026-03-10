module Api
  class EngineConfigsController < BaseController
    def update
      config = EngineConfig.find(params[:id])
      allowed = params.require(:engine_config).permit(
        :co2_percent, :co, :nox, :rated_rpm, :rated_hp,
        :operating_rpm, :target_load, :description
      )

      # Save engine name to both engine_config.description AND the associated engine
      if params[:engine_config][:engine].present?
        engine_name = params[:engine_config][:engine]
        allowed[:description] = engine_name
        if config.engine.present?
          config.engine.update_columns(description: engine_name, code: engine_name)
        end
      end

      if config.update(allowed)
        render json: config.as_json(include: :engine)
      else
        render json: { errors: config.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
