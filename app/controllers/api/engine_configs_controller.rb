module Api
  class EngineConfigsController < BaseController
    def update
      config = EngineConfig.find(params[:id])
      if config.update(params.require(:engine_config).permit!)
        render json: config.as_json
      else
        render json: { errors: config.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
