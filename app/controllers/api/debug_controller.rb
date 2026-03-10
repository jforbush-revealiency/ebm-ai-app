class Api::DebugController < ApplicationController
  def engine_configs
    configs = EngineConfig.includes(:engine).map do |ec|
      engine_name = ec.engine&.description || ec.engine&.code || ec.code || "Config ##{ec.id}"
      {
        id:           ec.id,
        code:         ec.code,
        engine_name:  engine_name,
        engine:       engine_name,
        co2_percent:  ec.co2_percent,
        co:           ec.co,
        nox:          ec.nox,
        rated_rpm:    ec.rated_rpm,
        rated_hp:     ec.rated_hp,
        operating_rpm: ec.operating_rpm,
        target_load:  ec.target_load
      }
    end
    render json: configs
  end
end
