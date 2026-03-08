class DiagnosticService
  def self.calculate_status(input)
    engine_config = input.vehicle&.engine_config
    return "unknown" unless engine_config

    def self.param(name, default)
      p = Parameter.find_by(code: name)
      p ? p.value.to_f : default
    end

    high_co2_pct     = param("High_CO2_Percentage",      0.25)
    elevated_co2_pct = param("Elevated_CO2_Percentage",  0.10)
    elevated_co      = param("Elevated_CO",              2.0)
    high_co          = param("High_CO",                  3.0)
    low_nox          = param("Low_NOx",                 -0.25)
    very_low_nox     = param("Very_Low_NOx",            -0.35)
    rpm_max          = param("Rated_RPM_Max",             0.10)
    rpm_min          = param("Rated_RPM_Min",            -0.20)

    issues = []

    # Average left + right banks
    co2_vals = [input.left_bank_co2_percent, input.right_bank_co2_percent].compact
    co_vals  = [input.left_bank_co, input.right_bank_co].compact
    nox_vals = [input.left_bank_nox, input.right_bank_nox].compact
    rpm_val  = input.engine_rpm

    avg_co2 = co2_vals.sum / co2_vals.size if co2_vals.any?
    avg_co  = co_vals.sum  / co_vals.size  if co_vals.any?
    avg_nox = nox_vals.sum / nox_vals.size if nox_vals.any?

    # CO2 check
    if avg_co2 && engine_config.co2_percent.present?
      delta = (avg_co2 - engine_config.co2_percent.to_f) / engine_config.co2_percent.to_f
      if delta > high_co2_pct
        issues << "critical"
      elsif delta > elevated_co2_pct
        issues << "marginal"
      end
    end

    # CO check
    if avg_co && engine_config.baseline_co.present?
      ratio = avg_co / engine_config.baseline_co.to_f
      if ratio > (1 + high_co)
        issues << "critical"
      elsif ratio > (1 + elevated_co)
        issues << "marginal"
      end
    end

    # NOx check
    if avg_nox && engine_config.baseline_nox.present?
      delta = (avg_nox - engine_config.baseline_nox.to_f) / engine_config.baseline_nox.to_f
      if delta < very_low_nox
        issues << "critical"
      elsif delta < low_nox
        issues << "marginal"
      end
    end

    # RPM check
    if rpm_val && engine_config.rated_rpm.present?
      delta = (rpm_val.to_f - engine_config.rated_rpm.to_f) / engine_config.rated_rpm.to_f
      issues << "marginal" if delta > rpm_max || delta < rpm_min
    end

    return "unknown" if issues.empty? && avg_co2.nil? && avg_co.nil?
    return "critical" if issues.include?("critical")
    return "marginal" if issues.include?("marginal")
    "in_spec"
  end
end
