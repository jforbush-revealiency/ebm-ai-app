class Output < ApplicationRecord
  belongs_to :input

  # ── Parameter Cache ──────────────────────────────────────────────────────────
  def self.parameter_cache
    @parameter_cache ||= Parameter.all.index_by(&:code)
  end

  def self.reload_parameter_cache!
    @parameter_cache = Parameter.all.index_by(&:code)
  end

  def param(code)
    self.class.parameter_cache[code]&.value
  end

  # ── Return Codes ─────────────────────────────────────────────────────────────
  def self.return_codes
    {
      ok_engine_hours:                                        'Message_ok_engine_hours',
      investigate_engine_hours:                               'Message_investigate_engine_hours',
      ok_engine_alternator_rpm_settings:                      'Message_ok_engine_alternator_rpm_settings',
      ok_engine_alternator_hp_settings:                       'Message_ok_engine_alternator_hp_settings',
      rated_rpm_limit_exceeded:                               'Message_rated_rpm_limit_exceeded',
      rated_rpm_max:                                          'Rated_RPM_Max',
      investigate_engine_or_drivetrain_alternator_parasitics: 'Message_investigate_engine_or_drivetrain_alternator_parasitics',
      rated_rpm_min:                                          'Rated_RPM_Min',
      ok_bank_balance_check:                                  'Message_ok_bank_balance_check',
      check_left_right_bank_performance:                      'Message_check_left_right_bank_performance',
      ok_co2_percentage_banks:                                'Message_ok_co2_percentage_banks',
      low_co2_percentage:                                     'Message_low_co2_percentage',
      elevated_co2_percentage_message:                        'Message_elevated_co2_percentage',
      elevated_co2_percentage:                                'Elevated_CO2_Percentage',
      high_co2_percentage_message:                            'Message_high_co2_percentage',
      high_co2_percentage:                                    'High_CO2_Percentage',
      ok_co_banks:                                            'Message_ok_co_banks',
      extremely_high_co:                                      'Message_extremely_high_co',
      elevated_co_message:                                    'Message_elevated_co',
      elevated_co:                                            'Elevated_CO',
      high_co_message:                                        'Message_high_co',
      high_co:                                                'High_CO',
      high_co_with_low_nox_message:                           'Message_high_co_with_low_nox',
      high_co_with_low_nox:                                   'High_CO_with_Low_NOx',
      ok_nox_banks:                                           'Message_ok_nox_banks',
      high_nox:                                               'Message_high_nox',
      low_nox_message:                                        'Message_low_nox',
      low_nox:                                                'Low_NOx',
      very_low_nox_message:                                   'Message_very_low_nox',
      very_low_nox:                                           'Very_Low_NOx',
    }
  end

  # ── Main Processing Entry Point ──────────────────────────────────────────────
  def self.process_input(input)
    Input.transaction do
      output = input.output || Output.new

      location      = input.vehicle.location
      engine_config = input.vehicle.engine_config
      engine        = engine_config.engine
      drive_type    = engine.drive_type
      vehicle       = input.vehicle

      previous_engine_hours = vehicle.previous_engine_hours(input)

      # Engine Hours
      output.engine_hours_code    = output.engine_hours_value(previous_engine_hours, input.engine_hours)
      output.engine_hours_message = output.set_message(output.engine_hours_code, [previous_engine_hours.to_i])

      # RPM Check
      output.engine_alternator_rpm_code    = output.engine_alternator_rpm_value(
        drive_type.code, input.engine_rpm, engine_config.default_rated_rpm, input.alternator_rpm
      )
      output.engine_alternator_rpm_message = output.set_message(output.engine_alternator_rpm_code)

      # HP Check
      output.engine_alternator_hp_code    = output.engine_alternator_hp_value(drive_type.code, input.engine_hp, input.alternator_hp)
      output.engine_alternator_hp_message = output.set_message(output.engine_alternator_hp_code)

      unless engine.is_single_stack
        # Bank Balance Checks
        output.bank_balance_check_co2_percent_code    = output.bank_balance_check(input.left_bank_co2_decimal, input.right_bank_co2_decimal)
        output.bank_balance_check_co2_percent_message = output.set_message(output.bank_balance_check_co2_percent_code)

        output.bank_balance_check_co_code    = output.bank_balance_check(input.left_bank_co, input.right_bank_co)
        output.bank_balance_check_co_message = output.set_message(output.bank_balance_check_co_code)

        output.bank_balance_check_nox_code    = output.bank_balance_check(input.left_bank_nox, input.right_bank_nox)
        output.bank_balance_check_nox_message = output.set_message(output.bank_balance_check_nox_code)
      end

      # CO2 Analysis
      output.co2_percent_left_bank_code    = output.co2_banks(input.left_bank_co2_decimal, engine_config.co2_decimal)
      output.co2_percent_left_bank_message = output.set_message(output.co2_percent_left_bank_code)

      # CO Analysis — manual tests only (CO cannot be measured via telematics)
      unless input.auto_generated?
        output.co_left_bank_code    = output.co_banks(input.left_bank_co, engine_config.co,
                                                      input.left_bank_nox, input.right_bank_nox, engine_config.nox)
        output.co_left_bank_message = output.set_message(output.co_left_bank_code)
      end

      output.nox_left_bank_code    = output.nox_banks(location.attainment, input.left_bank_nox, engine_config.nox)
      output.nox_left_bank_message = output.set_message(output.nox_left_bank_code)

      unless engine.is_single_stack
        output.co2_percent_right_bank_code    = output.co2_banks(input.right_bank_co2_decimal, engine_config.co2_decimal)
        output.co2_percent_right_bank_message = output.set_message(output.co2_percent_right_bank_code)

        unless input.auto_generated?
          output.co_right_bank_code    = output.co_banks(input.right_bank_co, engine_config.co,
                                                         input.left_bank_nox, input.right_bank_nox, engine_config.nox)
          output.co_right_bank_message = output.set_message(output.co_right_bank_code)
        end

        output.nox_right_bank_code    = output.nox_banks(location.attainment, input.right_bank_nox, engine_config.nox)
        output.nox_right_bank_message = output.set_message(output.nox_right_bank_code)
      end

      output.processed = DateTime.now
      output.input     = input

      # Use validate: false to allow imported records (auto_generated) to save
      # without requiring fully validated user/vehicle associations
      output.save!(validate: false)

      input.update_column(:output_id, output.id)

      # Do not email if auto_generated (telematics) or imports role
      unless input.auto_generated? || input.user.role?('imports')
        SystemMailer.results_email(output).deliver_later rescue nil
      end

      output
    end
  end

  # ── Message Lookup ───────────────────────────────────────────────────────────
  def set_message(message_code, values = nil)
    message = param(message_code)
    return nil if message.nil?
    values.present? ? (message % values rescue message) : message
  end

  # ── Diagnostic Methods ───────────────────────────────────────────────────────

  def engine_hours_value(previous_engine_hours, engine_hours)
    previous_engine_hours > engine_hours ?
      Output.return_codes[:investigate_engine_hours] :
      Output.return_codes[:ok_engine_hours]
  end

  def engine_alternator_rpm_value(drive_type, engine_rpm, engine_rpm_target, alternator_rpm)
    return Output.return_codes[:ok_engine_alternator_rpm_settings] if engine_rpm_target.to_f.zero?

    tolerance_max = param('Rated_RPM_Max').to_f
    tolerance_min = param('Rated_RPM_Min').to_f
    tolerance     = (engine_rpm - engine_rpm_target) / engine_rpm_target.to_f

    if tolerance >= tolerance_max
      Output.return_codes[:rated_rpm_limit_exceeded]
    elsif tolerance <= tolerance_min
      Output.return_codes[:investigate_engine_or_drivetrain_alternator_parasitics]
    else
      Output.return_codes[:ok_engine_alternator_rpm_settings]
    end
  end

  def engine_alternator_hp_value(drive_type, engine_hp, alternator_hp)
    # TODO: Implement HP tolerance check based on drive_type thresholds
    Output.return_codes[:ok_engine_alternator_hp_settings]
  end

  def bank_balance_check(left_bank, right_bank)
    return Output.return_codes[:ok_bank_balance_check] if left_bank.to_f.zero?
    return Output.return_codes[:ok_bank_balance_check] if right_bank.nil?

    bank_check_max = param('Bank_Check_Max').to_f
    tolerance      = ((left_bank - right_bank).abs / left_bank.to_f)

    tolerance > bank_check_max ?
      Output.return_codes[:check_left_right_bank_performance] :
      Output.return_codes[:ok_bank_balance_check]
  end

  def co2_banks(actual, target)
    return Output.return_codes[:ok_co2_percentage_banks] if target.to_f.zero?

    co2_elevated = param('Elevated_CO2_Percentage').to_f
    co2_high     = param('High_CO2_Percentage').to_f
    tolerance    = ((actual - target).abs / target.to_f)

    if tolerance > co2_elevated
      if actual < target
        Output.return_codes[:low_co2_percentage]
      elsif tolerance < co2_high
        Output.return_codes[:elevated_co2_percentage_message]
      else
        Output.return_codes[:high_co2_percentage_message]
      end
    else
      Output.return_codes[:ok_co2_percentage_banks]
    end
  end

  def co_banks(actual, target, left_bank_nox, right_bank_nox, nox_target)
    co_elevated     = param('Elevated_CO').to_f
    co_high         = param('High_CO').to_f
    high_co_low_nox = param('High_CO_with_Low_NOx').to_f

    if actual < (co_elevated * target)
      Output.return_codes[:ok_co_banks]
    elsif actual > 2000
      Output.return_codes[:extremely_high_co]
    elsif actual >= (co_elevated * target) && actual < (co_high * target)
      Output.return_codes[:elevated_co_message]
    else
      left_nox_tolerance  = (nox_target.nil? || nox_target.zero?) ? high_co_low_nox + 1 : left_bank_nox / nox_target.to_f
      right_nox_tolerance = (nox_target.nil? || nox_target.zero? || right_bank_nox.nil?) ? high_co_low_nox + 1 : right_bank_nox / nox_target.to_f

      if left_nox_tolerance <= high_co_low_nox || right_nox_tolerance <= high_co_low_nox
        Output.return_codes[:high_co_with_low_nox_message]
      else
        Output.return_codes[:high_co_message]
      end
    end
  end

  def nox_banks(attainment, actual, target)
    return Output.return_codes[:ok_nox_banks] if target.to_f.zero?

    tolerance    = (actual - target) / target.to_f
    nox_min      = param('Low_Nox').to_f
    very_low_min = param('Very_Low_Nox').to_f

    high_nox     = false
    low_nox      = false
    very_low_nox = false

    if attainment
      nox_max      = param('Nox_Upper_Max').to_f
      high_nox     = tolerance > nox_max
      very_low_nox = !high_nox && tolerance < very_low_min
      low_nox      = !high_nox && !very_low_nox && tolerance < nox_min
    else
      high_nox     = actual > target
      very_low_nox = !high_nox && tolerance < very_low_min
      low_nox      = !high_nox && !very_low_nox && tolerance < nox_min
    end

    if high_nox
      Output.return_codes[:high_nox]
    elsif very_low_nox
      Output.return_codes[:very_low_nox_message]
    elsif low_nox
      Output.return_codes[:low_nox_message]
    else
      Output.return_codes[:ok_nox_banks]
    end
  end

  # ── Email Styling Helpers ────────────────────────────────────────────────────

  def email_class_code(attribute)
    'row-success' if self[attribute]&.start_with?('Message_ok_')
  end

  def email_style_code(attribute)
    val = self[attribute].to_s
    if val.start_with?('Message_ok_')
      'background-color: #6abd45; color: #fff; text-align: center; font-size: 16px;'
    elsif val.include?('_extremely_')
      'background-color: #ce1a1a; color: #fff; text-align: left; font-size: 12px; padding-left: 5px; padding-right: 5px;'
    else
      'font-size: 12px;'
    end
  end

  # ── Delegated Input Accessors ────────────────────────────────────────────────
  delegate :submitter_first_name, :submitter_last_name, :submitter_email,
           :submitted, :engine_hours, :engine_rpm, :engine_hp,
           :alternator_rpm, :alternator_hp,
           :left_bank_co2_percent, :right_bank_co2_percent,
           :left_bank_co, :right_bank_co, :left_bank_nox, :right_bank_nox,
           :auto_generated, to: :input, prefix: false

  def company_code       = input.location.company.code
  def location_code      = input.location_code
  def vehicle_code       = input.vehicle_code
  def manufacturer_code  = input.vehicle.engine_config.engine.manufacturer.code
  def engine_code        = input.vehicle.engine_config.engine.code
  def drive_type         = input.vehicle.engine_config.engine.drive_type.code
  def is_single_stack    = input.is_single_stack
  def is_input_auto_generated = input.auto_generated

  def as_json(options = {})
    super(methods: [
      :submitter_first_name, :submitter_last_name, :submitter_email,
      :submitted, :company_code, :location_code, :vehicle_code, :manufacturer_code,
      :engine_code, :engine_hours, :is_single_stack,
      :engine_rpm, :engine_hp, :alternator_rpm, :alternator_hp,
      :left_bank_co2_percent, :right_bank_co2_percent,
      :left_bank_co, :right_bank_co, :left_bank_nox, :right_bank_nox,
      :is_input_auto_generated
    ])
  end
end
