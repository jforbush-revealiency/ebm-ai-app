class Api::DebugController < ApplicationController
  def engine_configs
    configs = EngineConfig.includes(:engine).map do |ec|
      {
        id:          ec.id,
        engine:      ec.engine&.code,
        co2_percent: ec.co2_percent,
        co:          ec.co,
        nox:         ec.nox,
        rated_rpm:   ec.rated_rpm,
        rated_hp:    ec.rated_hp
      }
    end
    render json: configs
  end

  def parameters
    render json: Parameter.all.map { |p| { id: p.id, code: p.code, value: p.value } }
  end
end
