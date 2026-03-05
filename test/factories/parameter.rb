FactoryGirl.define do
  factory :parameter do
  end

  factory :parameter_engine_parasitics_max, class: Parameter do
    code 'Engine_Parasitics_Max'
    value '.10'
  end

  factory :parameter_engine_parasitics_warning, class: Parameter do
    code 'Engine_Parasitics_Warning'
    value '.7'
  end

  factory :parameter_horse_power_variances_max, class: Parameter do
    code 'Horse_Power_Variances_Max'
    value '.0050'
  end

  factory :parameter_horse_power_variances_warning, class: Parameter do
    code 'Horse_Power_Variances_Warning'
    value '.0030'
  end

  factory :parameter_bank_check_max, class: Parameter do
    code 'Bank_Check_Max'
    value '.10'
  end

  factory :parameter_bank_check_warning, class: Parameter do
    code 'Bank_Check_Warning'
    value '.8'
  end

  factory :parameter_co2_percentage_max, class: Parameter do
    code 'CO2_Percentage_Max'
    value '.0025'
  end

  factory :parameter_co2_percentage_warning, class: Parameter do
    code 'CO2_Percentage_Warning'
    value '.0020'
  end

  factory :parameter_nox_upper_max, class: Parameter do
    code 'Nox_Upper_Max'
    value '.20'
  end

  factory :parameter_nox_upper_warning, class: Parameter do
    code 'Nox_Upper_Warning'
    value '.15'
  end

  factory :parameter_nox_lower_max, class: Parameter do
    code 'Nox_Lower_Max'
    value '-.20'
  end

  factory :parameter_nox_lower_warning, class: Parameter do
    code 'Nox_Lower_Warning'
    value '-.15'
  end
end

