class DiagnosticService
  def self.calculate_status(input)
    engine_config = input.engine_config
    return "unknown" unless engine_config

    # Load thresholds from parameters table
    def self.param(name, default)
      p = Parameter.find_by(name: name)
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

    # CO2 check
    if engine_config.baseline_co2_pct.present? && input.co2_pct.present?
      delta = (input.co2_pct.to_f - engine_config.baseline_co2_pct.to_f) / engine_config.baseline_co2_pct.to_f
      if delta > high_co2_pct
        issues << "critical"
      elsif delta > elevated_co2_pct
        issues << "marginal"
      end
    end

    # CO check
    if engine_config.baseline_co.present? && input.co.present?
      ratio = input.co.to_f / engine_config.baseline_co.to_f
      if ratio > (1 + high_co)
        issues << "critical"
      elsif ratio > (1 + elevated_co)
        issues << "marginal"
      end
    end

    # NOx check
    if engine_config.baseline_nox.present? && input.nox.present?
      delta = (input.nox.to_f - engine_config.baseline_nox.to_f) / engine_config.baseline_nox.to_f
      if delta < very_low_nox
        issues << "critical"
      elsif delta < low_nox
        issues << "marginal"
      end
    end

    # RPM check
    if engine_config.rated_rpm.present? && input.rpm.present?
      delta = (input.rpm.to_f - engine_config.rated_rpm.to_f) / engine_config.rated_rpm.to_f
      if delta > rpm_max || delta < rpm_min
        issues << "marginal"
      end
    end

    return "unknown" if issues.empty? && !input.co2_pct.present? && !input.co.present?
    return "critical" if issues.include?("critical")
    return "marginal" if issues.include?("marginal")
    "in_spec"
  end
end
