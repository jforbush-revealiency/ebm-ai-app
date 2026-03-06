module Api
  class DiagnosticController < BaseController

    def show
      input = Input.find(params[:id])
      vehicle = Vehicle.find_by(code: input.vehicle_code)
      engine_config = vehicle&.engine_config

      unless input && vehicle && engine_config
        render json: { error: "Input, vehicle, or engine config not found" }, status: :not_found
        return
      end

      # Load all parameters server-side — never exposed to frontend
      params_hash = Parameter.all.each_with_object({}) do |p, h|
        h[p.code] = p.value
      end

      # Thresholds
      very_low_nox     = params_hash['Very_Low_NOx'].to_f
      low_nox          = params_hash['Low_NOx'].to_f
      nox_upper_max    = params_hash['Nox_Upper_Max'].to_f
      elevated_co2     = params_hash['Elevated_CO2_Percentage'].to_f
      high_co2         = params_hash['High_CO2_Percentage'].to_f
      elevated_co_mult = params_hash['Elevated_CO'].to_f
      high_co_mult     = params_hash['High_CO'].to_f
      high_co_low_nox  = params_hash['High_CO_with_Low_NOx'].to_f
      bank_check_max   = params_hash['Bank_Check_Max'].to_f
      rpm_max          = params_hash['Rated_RPM_Max'].to_f
      rpm_min          = params_hash['Rated_RPM_Min'].to_f

      # Rated values from engine config
      rated_nox = engine_config.nox.to_f
      rated_co2 = engine_config.co2_percent.to_f
      rated_co  = engine_config.co.to_f
      rated_rpm = engine_config.rated_rpm.to_f
      rated_hp  = engine_config.rated_hp.to_f
      is_single_stack = engine_config.engine&.is_single_stack

      engine_hours_result = diagnose_engine_hours(input, params_hash)
      rpm_result          = diagnose_rpm(input.engine_rpm, rated_rpm, rpm_min, rpm_max, params_hash)
      hp_result           = diagnose_hp(input.engine_hp, rated_hp, params_hash)

      left_nox  = input.left_bank_nox.to_f
      right_nox = input.right_bank_nox.to_f
      left_co2  = input.left_bank_co2_percent.to_f
      right_co2 = input.right_bank_co2_percent.to_f
      left_co   = input.left_bank_co.to_f
      right_co  = input.right_bank_co.to_f

      left_co2_result  = diagnose_co2(left_co2, rated_co2, elevated_co2, high_co2, params_hash)
      right_co2_result = is_single_stack ? nil : diagnose_co2(right_co2, rated_co2, elevated_co2, high_co2, params_hash)

      left_co_result   = diagnose_co(left_co, rated_co, left_nox, rated_nox, elevated_co_mult, high_co_mult, high_co_low_nox, params_hash)
      right_co_result  = is_single_stack ? nil : diagnose_co(right_co, rated_co, right_nox, rated_nox, elevated_co_mult, high_co_mult, high_co_low_nox, params_hash)

      left_nox_result  = diagnose_nox(left_nox, rated_nox, very_low_nox, low_nox, nox_upper_max, params_hash
