class Api::DiagnosticController < ApplicationController
  def show
    input = Input.find(params[:input_id])
    output = input.output
    engine_config = input.vehicle&.engine_config

    # Pull parameter thresholds from DB or use defaults
    params_hash = Parameter.all.index_by(&:code)
    def p(code, default)
      params_hash[code]&.value&.to_f || default
    end

    bank_check_max   = p('Bank_Check_Max', 0.2)
    elevated_co      = p('Elevated_CO', 2.0)
    high_co          = p('High_CO', 3.0)
    high_co2_pct     = p('High_CO2_Percentage', 0.05)
    low_nox          = p('Low_NOx', -0.20)
    very_low_nox     = p('Very_Low_NOx', -0.25)
    nox_upper_max    = p('Nox_Upper_Max', 0.2)

    sections = {}

    # --- Engine Hours ---
    hours = input.engine_hours.to_f
    sections[:engine_hours] = if hours > 0
      { status: 'ok', message: 'Engine hours recorded', value: hours }
    else
      { status: 'unknown', message: 'Engine hours not recorded', value: nil }
    end

    # --- RPM ---
    rated_rpm = engine_config&.rated_rpm.to_f
    actual_rpm = input.engine_rpm.to_f
    sections[:rpm] = if rated_rpm > 0 && actual_rpm > 0
      variance = (actual_rpm - rated_rpm) / rated_rpm
      if variance.abs > 0.05
        { status: 'warning', message: "RPM variance #{(variance * 100).round(1)}% from rated #{rated_rpm.to_i}", value: actual_rpm }
      else
        { status: 'ok', message: "RPM within spec (#{actual_rpm.to_i} / #{rated_rpm.to_i} rated)", value: actual_rpm }
      end
    else
      { status: 'unknown', message: 'RPM data unavailable', value: actual_rpm > 0 ? actual_rpm : nil }
    end

    # --- HP ---
    rated_hp = engine_config&.rated_hp.to_f
    actual_hp = input.engine_hp.to_f
    sections[:hp] = if rated_hp > 0 && actual_hp > 0
      { status: 'ok', message: "HP within spec (#{actual_hp.to_i} / #{rated_hp.to_i} rated)", value: actual_hp }
    else
      { status: 'unknown', message: 'HP data unavailable', value: actual_hp > 0 ? actual_hp : nil }
    end

    # --- CO2 ---
    rated_co2 = engine_config&.co2_percent.to_f
    left_co2  = input.co2_percent_left.to_f
    right_co2 = input.co2_percent_right.to_f

    sections[:co2] = {}
    if rated_co2 > 0 && left_co2 > 0
      variance = (left_co2 - rated_co2) / rated_co2
      sections[:co2][:left] = if variance > high_co2_pct
        { status: 'warning', message: "High CO2: #{left_co2}% vs #{rated_co2}% rated", value: left_co2 }
      elsif variance < -high_co2_pct
        { status: 'warning', message: "Low CO2: #{left_co2}% vs #{rated_co2}% rated", value: left_co2 }
      else
        { status: 'ok', message: "CO2 within spec: #{left_co2}%", value: left_co2 }
      end
    else
      sections[:co2][:left] = { status: 'unknown', message: 'CO2 left bank data unavailable', value: left_co2 > 0 ? left_co2 : nil }
    end

    if rated_co2 > 0 && right_co2 > 0
      variance = (right_co2 - rated_co2) / rated_co2
      sections[:co2][:right] = if variance > high_co2_pct
        { status: 'warning', message: "High CO2: #{right_co2}% vs #{rated_co2}% rated", value: right_co2 }
      elsif variance < -high_co2_pct
        { status: 'warning', message: "Low CO2: #{right_co2}% vs #{rated_co2}% rated", value: right_co2 }
      else
        { status: 'ok', message: "CO2 within spec: #{right_co2}%", value: right_co2 }
      end
    else
      sections[:co2][:right] = { status: 'unknown', message: 'CO2 right bank data unavailable', value: right_co2 > 0 ? right_co2 : nil }
    end

    # --- CO ---
    rated_co = engine_config&.co.to_f
    left_co  = input.co_left.to_f
    right_co = input.co_right.to_f

    sections[:co] = {}
    if rated_co > 0 && left_co > 0
      ratio = left_co / rated_co
      sections[:co][:left] = if ratio >= high_co
        { status: 'warning', message: "WARNING: Extremely High CO Concentration (#{left_co.to_i} vs #{rated_co.to_i} rated)", value: left_co }
      elsif ratio >= elevated_co
        { status: 'caution', message: "Elevated CO detected (#{left_co.to_i} vs #{rated_co.to_i} rated)", value: left_co }
      else
        { status: 'ok', message: "CO within spec: #{left_co.to_i}", value: left_co }
      end
    else
      sections[:co][:left] = { status: 'unknown', message: 'CO left bank data unavailable', value: left_co > 0 ? left_co : nil }
    end

    if rated_co > 0 && right_co > 0
      ratio = right_co / rated_co
      sections[:co][:right] = if ratio >= high_co
        { status: 'warning', message: "WARNING: Extremely High CO Concentration (#{right_co.to_i} vs #{rated_co.to_i} rated)", value: right_co }
      elsif ratio >= elevated_co
        { status: 'caution', message: "Elevated CO detected (#{right_co.to_i} vs #{rated_co.to_i} rated)", value: right_co }
      else
        { status: 'ok', message: "CO within spec: #{right_co.to_i}", value: right_co }
      end
    else
      sections[:co][:right] = { status: 'unknown', message: 'CO right bank data unavailable', value: right_co > 0 ? right_co : nil }
    end

    # --- NOx ---
    rated_nox = engine_config&.nox.to_f
    left_nox  = input.nox_left.to_f
    right_nox = input.nox_right.to_f

    sections[:nox] = {}
    if rated_nox > 0 && left_nox > 0
      variance = (left_nox - rated_nox) / rated_nox
      sections[:nox][:left] = if variance < very_low_nox
        { status: 'warning', message: "Warning - Very Low NOx (#{left_nox.to_i} vs #{rated_nox.to_i} rated)", value: left_nox }
      elsif variance < low_nox
        { status: 'caution', message: "Caution - Low NOx (#{left_nox.to_i} vs #{rated_nox.to_i} rated)", value: left_nox }
      elsif variance > nox_upper_max
        { status: 'caution', message: "Elevated NOx (#{left_nox.to_i} vs #{rated_nox.to_i} rated)", value: left_nox }
      else
        { status: 'ok', message: "NOx within spec: #{left_nox.to_i}", value: left_nox }
      end
    else
      sections[:nox][:left] = { status: 'unknown', message: 'NOx left bank data unavailable', value: left_nox > 0 ? left_nox : nil }
    end

    if rated_nox > 0 && right_nox > 0
      variance = (right_nox - rated_nox) / rated_nox
      sections[:nox][:right] = if variance < very_low_nox
        { status: 'warning', message: "Warning - Very Low NOx (#{right_nox.to_i} vs #{rated_nox.to_i} rated)", value: right_nox }
      elsif variance < low_nox
        { status: 'caution', message: "Caution - Low NOx (#{right_nox.to_i} vs #{rated_nox.to_i} rated)", value: right_nox }
      elsif variance > nox_upper_max
        { status: 'caution', message: "Elevated NOx (#{right_nox.to_i} vs #{rated_nox.to_i} rated)", value: right_nox }
      else
        { status: 'ok', message: "NOx within spec: #{right_nox.to_i}", value: right_nox }
      end
    else
      sections[:nox][:right] = { status: 'unknown', message: 'NOx right bank data unavailable', value: right_nox > 0 ? right_nox : nil }
    end

    # --- Bank Balance ---
    if left_co2 > 0 && right_co2 > 0
      avg = (left_co2 + right_co2) / 2.0
      variance = avg > 0 ? (left_co2 - right_co2).abs / avg : 0
      sections[:bank_balance] = if variance > bank_check_max
        { status: 'warning', message: "Bank imbalance detected: #{(variance * 100).round(1)}% CO2 variance", value: variance }
      else
        { status: 'ok', message: "Banks balanced within spec", value: variance }
      end
    end

    # --- Overall Status ---
    all_statuses = sections.values.flat_map { |v| v.is_a?(Hash) && v[:status] ? [v[:status]] : v.values.map { |s| s[:status] } rescue [] }
    overall = if all_statuses.include?('warning') then 'warning'
               elsif all_statuses.include?('caution') then 'caution'
               else 'ok' end

    render json: {
      input_id:      input.id,
      vehicle_code:  input.vehicle&.code,
      submitted:     input.created_at&.strftime('%Y-%m-%d'),
      engine_hours:  hours > 0 ? hours : nil,
      test_type:     input.test_type || 'manual',
      overall_status: overall,
      sections:      sections
    }

  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Input not found' }, status: :not_found
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
