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

      params_hash = Parameter.all.each_with_object({}) do |p, h|
        h[p.code] = p.value
      end

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

      rated_nox = engine_config.nox.to_f
      rated_co2 = engine_config.co2_percent.to_f
      rated_co  = engine_config.co.to_f
      rated_rpm = engine_config.rated_rpm.to_f
      rated_hp  = engine_config.rated_hp.to_f
      is_single_stack = engine_config.engine&.is_single_stack
      is_telematic    = input.auto_generated?

      left_nox  = input.left_bank_nox.to_f
      right_nox = input.right_bank_nox.to_f
      left_co2  = input.left_bank_co2_percent.to_f
      right_co2 = input.right_bank_co2_percent.to_f
      left_co   = input.left_bank_co.to_f
      right_co  = input.right_bank_co.to_f

      engine_hours_result = diagnose_engine_hours(input, params_hash)
      rpm_result          = diagnose_rpm(input.engine_rpm, rated_rpm, rpm_min, rpm_max, params_hash)
      hp_result           = diagnose_hp(input.engine_hp, rated_hp, params_hash)
      left_co2_result     = diagnose_co2(left_co2, rated_co2, elevated_co2, high_co2, params_hash)
      right_co2_result    = is_single_stack ? nil : diagnose_co2(right_co2, rated_co2, elevated_co2, high_co2, params_hash)
      left_co_result      = diagnose_co(left_co, rated_co, left_nox, rated_nox, elevated_co_mult, high_co_mult, high_co_low_nox, is_telematic, params_hash)
      right_co_result     = is_single_stack ? nil : diagnose_co(right_co, rated_co, right_nox, rated_nox, elevated_co_mult, high_co_mult, high_co_low_nox, is_telematic, params_hash)
      left_nox_result     = diagnose_nox(left_nox, rated_nox, very_low_nox, low_nox, nox_upper_max, params_hash)
      right_nox_result    = is_single_stack ? nil : diagnose_nox(right_nox, rated_nox, very_low_nox, low_nox, nox_upper_max, params_hash)
      bank_balance_result = is_single_stack ? nil : diagnose_bank_balance(left_nox, right_nox, left_co2, right_co2, bank_check_max, params_hash)

      render json: {
        input_id:         input.id,
        vehicle:          vehicle.description,
        vehicle_code:     vehicle.code,
        engine:           engine_config.description,
        is_single_stack:  is_single_stack,
        test_type:        is_telematic ? 'telematic' : 'manual',
        has_engine_codes: input.has_engine_codes,
        actuals: {
          engine_hours:   input.engine_hours,
          engine_rpm:     input.engine_rpm,
          alternator_rpm: input.alternator_rpm,
          engine_hp:      input.engine_hp,
          alternator_hp:  input.alternator_hp
        },
        sections: {
          engine_hours: engine_hours_result,
          rpm:          rpm_result,
          hp:           hp_result,
          co2: { left: left_co2_result, right: right_co2_result },
          co:  { left: left_co_result,  right: right_co_result  },
          nox: { left: left_nox_result, right: right_nox_result },
          bank_balance: bank_balance_result
        }
      }
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Input not found" }, status: :not_found
    end

    private

    def diagnose_engine_hours(input, p)
      { status: 'ok', value: input.engine_hours, message: 'OK' }
    end

    def diagnose_rpm(actual_rpm, rated_rpm, rpm_min, rpm_max, p)
      return { status: 'unknown', message: 'No RPM data' } if actual_rpm.nil? || rated_rpm.zero?
      ratio = (actual_rpm.to_f - rated_rpm) / rated_rpm
      if ratio > rpm_max
        { status: 'warning', value: actual_rpm, message: p['Message_rated_rpm_limit_exceeded'] || 'Check Alternator settings or torque convertor stall point.' }
      elsif ratio < rpm_min
        { status: 'warning', value: actual_rpm, message: p['Message_investigate_engine_alternator_rpm_settings'] || 'Investigate Engine/Alternator RPM settings' }
      else
        { status: 'ok', value: actual_rpm, message: 'OK' }
      end
    end

    def diagnose_hp(engine_hp, rated_hp, p)
      return { status: 'unknown', message: 'No HP data' } if engine_hp.nil? || rated_hp.zero?
      ratio = (engine_hp.to_f - rated_hp).abs / rated_hp
      if ratio > p['Horse_Power_Variances_Max'].to_f
        { status: 'warning', value: engine_hp, message: p['Message_investigate_engine_or_drivetrain_alternator_parasitics'] || 'Investigate engine or drivetrain alternator parasitics' }
      else
        { status: 'ok', value: engine_hp, message: 'OK' }
      end
    end

    def diagnose_co2(actual_co2, rated_co2, elevated_co2, high_co2, p)
      return { status: 'unknown', message: 'No CO2 data' } if actual_co2.zero? || rated_co2.zero?
      ratio = (actual_co2 - rated_co2) / rated_co2
      if ratio > high_co2
        { status: 'warning', value: actual_co2, message: p['Message_high_co2_percentage'] || 'Warning - High CO2%' }
      elsif ratio > elevated_co2
        { status: 'caution', value: actual_co2, message: p['Message_elevated_co2_percentage'] || 'Caution - Elevated CO2%' }
      elsif ratio < -high_co2
        { status: 'caution', value: actual_co2, message: p['Message_low_co2_percentage'] || 'Caution - Low CO2%' }
      else
        { status: 'ok', value: actual_co2, message: 'OK' }
      end
    end

    def diagnose_co(actual_co, rated_co, actual_nox, rated_nox, elevated_mult, high_mult, high_co_low_nox, is_telematic, p)
      return { status: 'skip', message: 'CO not measured (telematic)' } if is_telematic
      nox_ratio = rated_nox.zero? ? 0 : (actual_nox - rated_nox) / rated_nox
      if actual_co >= rated_co * high_mult
        { status: 'warning', value: actual_co, message: p['Message_extremely_high_co'] || 'Warning - Extremely High CO Concentration' }
      elsif actual_co >= rated_co * elevated_mult && nox_ratio < high_co_low_nox
        { status: 'warning', value: actual_co, message: p['Message_high_co_with_low_nox'] || 'Warning - High CO with Low NOx' }
      elsif actual_co >= rated_co * elevated_mult
        { status: 'caution', value: actual_co, message: p['Message_high_co'] || 'Caution - High CO' }
      elsif actual_co > rated_co
        { status: 'notice', value: actual_co, message: p['Message_elevated_co'] || 'Notice - Elevated CO' }
      else
        { status: 'ok', value: actual_co, message: 'OK' }
      end
    end

    def diagnose_nox(actual_nox, rated_nox, very_low_nox, low_nox, nox_upper_max, p)
      return { status: 'unknown', message: 'No NOx data' } if actual_nox.zero? || rated_nox.zero?
      ratio = (actual_nox - rated_nox) / rated_nox
      if ratio < very_low_nox
        { status: 'warning', value: actual_nox, message: p['Message_very_low_nox'] || 'Warning - Very Low NOx' }
      elsif ratio < low_nox
        { status: 'caution', value: actual_nox, message: p['Message_low_nox'] || 'Caution - Low NOx' }
      elsif ratio > nox_upper_max
        { status: 'warning', value: actual_nox, message: p['Message_high_nox'] || 'Warning - High NOx' }
      else
        { status: 'ok', value: actual_nox, message: 'OK' }
      end
    end

    def diagnose_bank_balance(left_nox, right_nox, left_co2, right_co2, bank_check_max, p)
      nox_variance = bank_variance(left_nox, right_nox)
      co2_variance = bank_variance(left_co2, right_co2)
      if nox_variance > bank_check_max || co2_variance > bank_check_max
        { status: 'warning', message: p['Message_check_left_right_bank_performance'] || 'Check Left/Right Bank Performance' }
      else
        { status: 'ok', message: 'OK' }
      end
    end

    def bank_variance(left, right)
      avg = (left + right) / 2.0
      return 0 if avg.zero?
      (left - right).abs / avg
    end

  end
end