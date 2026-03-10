module Api
  class EngineConfigsController < BaseController
    def update
      config = EngineConfig.find(params[:id])
      allowed = params.require(:engine_config).permit(
        :engine, :co2_percent, :co, :nox, :rated_rpm, :rated_hp,
        :operating_rpm, :target_load
      )

      # 'engine' column conflicts with belongs_to :engine association
      # so we must write it directly to bypass the association setter
      if allowed.key?("engine")
        config.write_attribute(:engine, allowed.delete("engine"))
      end

      if config.update(allowed)
        render json: config.as_json
      else
        render json: { errors: config.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
