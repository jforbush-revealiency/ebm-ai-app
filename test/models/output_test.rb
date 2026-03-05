require 'test_helper'

class OutputTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Engine Alternator RPM Value is OK" do
    output = Output.new
    rated_rpm_max = create(:parameter, code: 'Rated_RPM_Max', value: ".10")
    rated_rpm_min = create(:parameter, code: 'Rated_RPM_Min', value: "-.20")
    return_code = output.engine_alternator_rpm_value("Mechanical", 1900, 1900, 1800)
    assert_equal(Output.return_codes[:ok_engine_alternator_rpm_settings], return_code)
  end

  test "Engine Alternator RPM Value is 10% above rated RPM on engine config" do
    output = Output.new
    rated_rpm_max = create(:parameter, code: 'Rated_RPM_Max', value: ".10")
    rated_rpm_min = create(:parameter, code: 'Rated_RPM_Min', value: "-.20")
    return_code = output.engine_alternator_rpm_value("Electric", 2090, 1900, 1800)
    assert_equal(Output.return_codes[:rated_rpm_limit_exceeded], return_code)
  end

  test "Engine Alternator RPM Value is 20% below rated RPM on engine config" do
    output = Output.new
    rated_rpm_max = create(:parameter, code: 'Rated_RPM_Max', value: ".10")
    rated_rpm_min = create(:parameter, code: 'Rated_RPM_Min', value: "-.20")
    return_code = output.engine_alternator_rpm_value("Electric", 1520, 1900, 1800)
    assert_equal(Output.return_codes[:investigate_engine_or_drivetrain_alternator_parasitics], return_code)
  end

  test "Engine Alternator HP Value is OK" do
    output = Output.new
    return_code = output.engine_alternator_hp_value("Mechanical", 2300, 2300)
    assert_equal(Output.return_codes[:ok_engine_alternator_hp_settings], return_code)
  end

  test "Engine Alternator HP Value is outside tolerance (should be ok)" do
    output = Output.new
    parameter = create(:parameter, code: 'Horse_Power_Variances_Max', value: ".005")
    return_code = output.engine_alternator_hp_value("Electric", 2200, 2300)
    assert_equal(Output.return_codes[:ok_engine_alternator_hp_settings], return_code)
  end

  test "Engine Alternator HP Value is within tolerance" do
    output = Output.new
    parameter = create(:parameter, code: 'Horse_Power_Variances_Max', value: ".005")
    return_code = output.engine_alternator_hp_value("Electric", 2288.6, 2300)
    assert_equal(Output.return_codes[:ok_engine_alternator_hp_settings], return_code)
  end

  test "Bank Balance Check is outside tolerance" do
    output = Output.new
    parameter = create(:parameter, code: 'Bank_Check_Max', value: ".1")
    return_code = output.bank_balance_check(88, 100)
    assert_equal(Output.return_codes[:check_left_right_bank_performance], return_code)
  end

  test "Bank Balance Check is within tolerance" do
    output = Output.new
    parameter = create(:parameter, code: 'Bank_Check_Max', value: ".1")
    return_code = output.bank_balance_check(100, 100)
    assert_equal(Output.return_codes[:ok_bank_balance_check], return_code)
  end

  test "CO2 Percentage is OK" do
    output = Output.new
    elevated_co2_parameter = create(:parameter, code: 'Elevated_CO2_Percentage', value: ".0025")
    high_co2_parameter = create(:parameter, code: 'High_CO2_Percentage', value: ".05")
    return_code = output.co2_banks(0.10, 0.10)
    assert_equal(Output.return_codes[:ok_co2_percentage_banks], return_code)
  end

  test "CO2 Percentage is Elevated" do
    output = Output.new
    elevated_co2_parameter = create(:parameter, code: 'Elevated_CO2_Percentage', value: ".0025")
    high_co2_parameter = create(:parameter, code: 'High_CO2_Percentage', value: ".05")
    return_code = output.co2_banks(0.1009, 0.10)
    assert_equal(Output.return_codes[:elevated_co2_percentage_message], return_code)
  end

  test "CO2 Percentage is High" do
    output = Output.new
    elevated_co2_parameter = create(:parameter, code: 'Elevated_CO2_Percentage', value: ".0025")
    high_co2_parameter = create(:parameter, code: 'High_CO2_Percentage', value: ".05")
    return_code = output.co2_banks(0.11, 0.10)
    assert_equal(Output.return_codes[:high_co2_percentage_message], return_code)
  end

  test "CO2 Percentage is Low" do
    output = Output.new
    elevated_co2_parameter = create(:parameter, code: 'Elevated_CO2_Percentage', value: ".0025")
    high_co2_parameter = create(:parameter, code: 'High_CO2_Percentage', value: ".05")
    return_code = output.co2_banks(0.09, 0.10)
    assert_equal(Output.return_codes[:low_co2_percentage], return_code)
  end

  test "CO is OK" do
    output = Output.new
    high_parameter = create(:parameter, code: 'High_CO', value: "3")
    elevated_parameter = create(:parameter, code: 'Elevated_CO', value: "2")
    high_co_nox_parameter = create(:parameter, code: 'High_CO_with_Low_NOx', value: ".80")
    return_code = output.co_banks(90, 90, 120, 120, 120)
    assert_equal(Output.return_codes[:ok_co_banks], return_code)
  end

  test "CO is Elevated" do
    output = Output.new
    high_parameter = create(:parameter, code: 'High_CO', value: "3")
    elevated_parameter = create(:parameter, code: 'Elevated_CO', value: "2")
    high_co_nox_parameter = create(:parameter, code: 'High_CO_with_Low_NOx', value: ".80")
    return_code = output.co_banks(180, 90, 120, 120, 120)
    assert_equal(Output.return_codes[:elevated_co_message], return_code)
  end

  test "CO is High" do
    output = Output.new
    high_parameter = create(:parameter, code: 'High_CO', value: "3")
    elevated_parameter = create(:parameter, code: 'Elevated_CO', value: "2")
    high_co_nox_parameter = create(:parameter, code: 'High_CO_with_Low_NOx', value: ".80")
    return_code = output.co_banks(272, 90, 120, 120, 120)
    assert_equal(Output.return_codes[:high_co_message], return_code)
  end

  test "CO is High with Low NOx" do
    output = Output.new
    high_parameter = create(:parameter, code: 'High_CO', value: "3")
    elevated_parameter = create(:parameter, code: 'Elevated_CO', value: "2")
    high_co_nox_parameter = create(:parameter, code: 'High_CO_with_Low_NOx', value: ".80")
    return_code = output.co_banks(272, 90, 120, 120, 150)
    assert_equal(Output.return_codes[:high_co_with_low_nox_message], return_code)
  end

  test "CO is High with High NOx" do
    output = Output.new
    high_parameter = create(:parameter, code: 'High_CO', value: "3")
    elevated_parameter = create(:parameter, code: 'Elevated_CO', value: "2")
    high_co_nox_parameter = create(:parameter, code: 'High_CO_with_Low_NOx', value: ".80")
    return_code = output.co_banks(272, 90, 160, 160, 144)
    assert_equal(Output.return_codes[:high_co_message], return_code)
  end

  test "CO is High with no NOx target" do
    output = Output.new
    high_parameter = create(:parameter, code: 'High_CO', value: "3")
    elevated_parameter = create(:parameter, code: 'Elevated_CO', value: "2")
    high_co_nox_parameter = create(:parameter, code: 'High_CO_with_Low_NOx', value: ".80")
    return_code = output.co_banks(272, 90, 160, 160, 0)
    assert_equal(Output.return_codes[:high_co_message], return_code)
  end

  test "CO is High with no right bank NOx" do
    output = Output.new
    high_parameter = create(:parameter, code: 'High_CO', value: "3")
    elevated_parameter = create(:parameter, code: 'Elevated_CO', value: "2")
    high_co_nox_parameter = create(:parameter, code: 'High_CO_with_Low_NOx', value: ".80")
    return_code = output.co_banks(272, 90, 120, nil, 150 )
    assert_equal(Output.return_codes[:high_co_with_low_nox_message], return_code)
  end

  test "CO is Extremely High" do
    output = Output.new
    high_parameter = create(:parameter, code: 'High_CO', value: "3")
    elevated_parameter = create(:parameter, code: 'Elevated_CO', value: "2")
    high_co_nox_parameter = create(:parameter, code: 'High_CO_with_Low_NOx', value: ".80")
    return_code = output.co_banks(2001, 90, 120, 120, 120)
    assert_equal(Output.return_codes[:extremely_high_co], return_code)
  end

  test "NOx is OK attainment" do
    output = Output.new
    upper_parameter = create(:parameter, code: 'Nox_Upper_Max', value: ".20")
    low_nox_parameter = create(:parameter, code: 'Low_NOx', value: "-.20")
    very_low_nox_parameter = create(:parameter, code: 'Very_Low_NOx', value: "-.25")
    return_code = output.nox_banks(true, 390, 380)
    assert_equal(Output.return_codes[:ok_nox_banks], return_code)
  end

  test "NOx is OK non-attainment" do
    output = Output.new
    upper_parameter = create(:parameter, code: 'Nox_Upper_Max', value: ".20")
    low_nox_parameter = create(:parameter, code: 'Low_NOx', value: "-.20")
    very_low_nox_parameter = create(:parameter, code: 'Very_Low_NOx', value: "-.25")
    return_code = output.nox_banks(false, 370, 380)
    assert_equal(Output.return_codes[:ok_nox_banks], return_code)
  end

  test "NOx is High attainment" do
    output = Output.new
    upper_parameter = create(:parameter, code: 'Nox_Upper_Max', value: ".20")
    low_nox_parameter = create(:parameter, code: 'Low_NOx', value: "-.20")
    very_low_nox_parameter = create(:parameter, code: 'Very_Low_NOx', value: "-.25")
    return_code = output.nox_banks(true, 457, 380)
    assert_equal(Output.return_codes[:high_nox], return_code)
  end

  test "NOx is High non-attainment" do
    output = Output.new
    upper_parameter = create(:parameter, code: 'Nox_Upper_Max', value: ".20")
    low_nox_parameter = create(:parameter, code: 'Low_NOx', value: "-.20")
    very_low_nox_parameter = create(:parameter, code: 'Very_Low_NOx', value: "-.25")
    return_code = output.nox_banks(false, 381, 380)
    assert_equal(Output.return_codes[:high_nox], return_code)
  end

  test "NOx is Low attainment" do
    output = Output.new
    upper_parameter = create(:parameter, code: 'Nox_Upper_Max', value: ".20")
    low_nox_parameter = create(:parameter, code: 'Low_NOx', value: "-.20")
    very_low_nox_parameter = create(:parameter, code: 'Very_Low_NOx', value: "-.25")
    return_code = output.nox_banks(true, 303, 380)
    assert_equal(Output.return_codes[:low_nox_message], return_code)
  end

  test "NOx is Very Low attainment" do
    output = Output.new
    upper_parameter = create(:parameter, code: 'Nox_Upper_Max', value: ".20")
    low_nox_parameter = create(:parameter, code: 'Low_NOx', value: "-.20")
    very_low_nox_parameter = create(:parameter, code: 'Very_Low_NOx', value: "-.25")
    return_code = output.nox_banks(true, 284, 380)
    assert_equal(Output.return_codes[:very_low_nox_message], return_code)
  end

  test "NOx is Very Low non-attainment" do
    output = Output.new
    upper_parameter = create(:parameter, code: 'Nox_Upper_Max', value: ".20")
    low_nox_parameter = create(:parameter, code: 'Low_NOx', value: "-.20")
    very_low_nox_parameter = create(:parameter, code: 'Very_Low_NOx', value: "-.25")
    return_code = output.nox_banks(false, 284, 380)
    assert_equal(Output.return_codes[:very_low_nox_message], return_code)
  end

  test "Engine Hours is OK with the first input record" do
    input = create(:input_attainment, has_engine_codes: false, 
                   engine_hours: 1500, engine_rpm: 1800, alternator_rpm: 1800, 
                   engine_hp: 2300,  alternator_hp: 2300, 
                   left_bank_co2_percent: 0.10, left_bank_co: 90, left_bank_nox: 390, 
                   right_bank_co2_percent: 0.10, right_bank_co: 90, right_bank_nox: 390) 
    output = Output.new
    return_code = output.engine_hours_value(input.vehicle.previous_engine_hours(input), input.engine_hours)
    assert_equal(Output.return_codes[:ok_engine_hours], return_code)
  end

  test "Engine Hours is OK with a previous input record" do
    input1 = create(:input_attainment, has_engine_codes: false, 
                   engine_hours: 1500, engine_rpm: 1800, alternator_rpm: 1800, 
                   engine_hp: 2300,  alternator_hp: 2300, 
                   left_bank_co2_percent: 0.10, left_bank_co: 90, left_bank_nox: 390, 
                   right_bank_co2_percent: 0.10, right_bank_co: 90, right_bank_nox: 390) 
    input2 = create(:input_attainment_without_vehicle, has_engine_codes: false, 
                   engine_hours: 1600, engine_rpm: 1800, alternator_rpm: 1800, 
                   engine_hp: 2300,  alternator_hp: 2300, 
                   left_bank_co2_percent: 0.10, left_bank_co: 90, left_bank_nox: 390, 
                   right_bank_co2_percent: 0.10, right_bank_co: 90, right_bank_nox: 390, 
                   vehicle: input1.vehicle) 
    output = Output.new
    return_code = output.engine_hours_value(input2.vehicle.previous_engine_hours(input2), input2.engine_hours)
    assert_equal(Output.return_codes[:ok_engine_hours], return_code)
  end

  test "Investiage engine hours with a single previous input record" do
    input1 = create(:input_attainment, has_engine_codes: false, 
                   engine_hours: 1500, engine_rpm: 1800, alternator_rpm: 1800, 
                   engine_hp: 2300,  alternator_hp: 2300, 
                   left_bank_co2_percent: 0.10, left_bank_co: 90, left_bank_nox: 390, 
                   right_bank_co2_percent: 0.10, right_bank_co: 90, right_bank_nox: 390) 
    input2 = create(:input_attainment_without_vehicle, has_engine_codes: false, 
                   engine_hours: 1400, engine_rpm: 1800, alternator_rpm: 1800, 
                   engine_hp: 2300,  alternator_hp: 2300, 
                   left_bank_co2_percent: 0.10, left_bank_co: 90, left_bank_nox: 390, 
                   right_bank_co2_percent: 0.10, right_bank_co: 90, right_bank_nox: 390, 
                   vehicle: input1.vehicle) 
    output = Output.new
    return_code = output.engine_hours_value(input2.vehicle.previous_engine_hours(input2), input2.engine_hours)
    assert_equal(Output.return_codes[:investigate_engine_hours], return_code)
  end

  test "Investiage engine hours with two previous input records" do
    input1 = create(:input_attainment, has_engine_codes: false, 
                   engine_hours: 1300, engine_rpm: 1800, alternator_rpm: 1800, 
                   engine_hp: 2300,  alternator_hp: 2300, 
                   left_bank_co2_percent: 0.10, left_bank_co: 90, left_bank_nox: 390, 
                   right_bank_co2_percent: 0.10, right_bank_co: 90, right_bank_nox: 390) 
    input2 = create(:input_attainment_without_vehicle, has_engine_codes: false, 
                   engine_hours: 1500, engine_rpm: 1800, alternator_rpm: 1800, 
                   engine_hp: 2300,  alternator_hp: 2300, 
                   left_bank_co2_percent: 0.10, left_bank_co: 90, left_bank_nox: 390, 
                   right_bank_co2_percent: 0.10, right_bank_co: 90, right_bank_nox: 390,
                   vehicle: input1.vehicle) 
    input3 = create(:input_attainment_without_vehicle, has_engine_codes: false, 
                   engine_hours: 1400, engine_rpm: 1800, alternator_rpm: 1800, 
                   engine_hp: 2300,  alternator_hp: 2300, 
                   left_bank_co2_percent: 0.10, left_bank_co: 90, left_bank_nox: 390, 
                   right_bank_co2_percent: 0.10, right_bank_co: 90, right_bank_nox: 390, 
                   vehicle: input1.vehicle) 
    output = Output.new
    return_code = output.engine_hours_value(input3.vehicle.previous_engine_hours(input3), input3.engine_hours)
    assert_equal(Output.return_codes[:investigate_engine_hours], return_code)
  end

  test "Set Message without values" do
    engine_hours_parameter = create(:parameter, code: 'Message_ok_engine_hours', value: "OK")
    output = Output.new
    message = output.set_message("Message_ok_engine_hours")
    assert_equal(message, "OK")
  end

  test "Set Message with values" do
    engine_hours_parameter = create(:parameter, code: 'Message_investigate_engine_hours', value: "OK %s and %s")
    output = Output.new
    message = output.set_message("Message_investigate_engine_hours", [23.3, 45.2])
    assert_equal(message, "OK 23.3 and 45.2")
  end

  test "Process Input attainment ok" do
    input = create(:input_attainment, has_engine_codes: false, 
                   engine_hours: 1500, engine_rpm: 1800, alternator_rpm: 1800, 
                   engine_hp: 2300,  alternator_hp: 2300, 
                   left_bank_co2_percent: 0.10, left_bank_co: 90, left_bank_nox: 390, 
                   right_bank_co2_percent: 0.10, right_bank_co: 90, right_bank_nox: 390) 

    rated_rpm_max = create(:parameter, code: 'Rated_RPM_Max', value: ".10")
    high_parameter = create(:parameter, code: 'High_CO', value: "3")
    elevated_parameter = create(:parameter, code: 'Elevated_CO', value: "2")
    rated_rpm_min = create(:parameter, code: 'Rated_RPM_Min', value: "-.20")
    bank_check_parameter = create(:parameter, code: 'Bank_Check_Max', value: ".1")
    parasitics_parameter = create(:parameter, code: 'Engine_Parasitics_Max', value: ".10")
    hp_parameter = create(:parameter, code: 'Horse_Power_Variances_Max', value: ".005")
    elevated_co2_parameter = create(:parameter, code: 'Elevated_CO2_Percentage', value: ".0025")
    high_co2_parameter = create(:parameter, code: 'High_CO2_Percentage', value: ".05")
    upper_parameter = create(:parameter, code: 'Nox_Upper_Max', value: ".20")
    low_nox_parameter = create(:parameter, code: 'Low_NOx', value: "-.20")
    very_low_nox_parameter = create(:parameter, code: 'Very_Low_NOx', value: "-.25")
    high_co_nox_parameter = create(:parameter, code: 'High_CO_with_Low_NOx', value: ".80")

    Output.return_codes.each {|key, value|
      parameter = create(:parameter, code: value)
    }

    output = Output.process_input(input)
    assert_equal(Output.return_codes[:ok_engine_hours], output.engine_hours_code)
    assert_equal(Output.return_codes[:ok_engine_alternator_rpm_settings], output.engine_alternator_rpm_code)
    assert_equal(Output.return_codes[:ok_engine_alternator_hp_settings], output.engine_alternator_hp_code)
    assert_equal(Output.return_codes[:ok_bank_balance_check], output.bank_balance_check_co2_percent_code)
    assert_equal(Output.return_codes[:ok_bank_balance_check], output.bank_balance_check_co_code)
    assert_equal(Output.return_codes[:ok_bank_balance_check], output.bank_balance_check_nox_code)
    assert_equal(Output.return_codes[:ok_co2_percentage_banks], output.co2_percent_left_bank_code)
    assert_equal(Output.return_codes[:ok_co2_percentage_banks], output.co2_percent_right_bank_code)
    assert_equal(Output.return_codes[:ok_co_banks], output.co_left_bank_code)
    assert_equal(Output.return_codes[:ok_co_banks], output.co_right_bank_code)
    assert_equal(Output.return_codes[:ok_nox_banks], output.nox_left_bank_code)
    assert_equal(Output.return_codes[:ok_nox_banks], output.nox_right_bank_code)
  end

  test "Process Input single stack" do
    input = create(:input_single_stack, has_engine_codes: false, 
                   engine_hours: 1500, engine_rpm: 1800, alternator_rpm: 1800, 
                   engine_hp: 2300,  alternator_hp: 2300, 
                   left_bank_co2_percent: 0.10, left_bank_co: 90, left_bank_nox: 390) 

    rated_rpm_max = create(:parameter, code: 'Rated_RPM_Max', value: ".10")
    high_parameter = create(:parameter, code: 'High_CO', value: "3")
    elevated_parameter = create(:parameter, code: 'Elevated_CO', value: "2")
    rated_rpm_min = create(:parameter, code: 'Rated_RPM_Min', value: "-.20")
    bank_check_parameter = create(:parameter, code: 'Bank_Check_Max', value: ".1")
    parasitics_parameter = create(:parameter, code: 'Engine_Parasitics_Max', value: ".10")
    hp_parameter = create(:parameter, code: 'Horse_Power_Variances_Max', value: ".005")
    elevated_co2_parameter = create(:parameter, code: 'Elevated_CO2_Percentage', value: ".0025")
    high_co2_parameter = create(:parameter, code: 'High_CO2_Percentage', value: ".05")
    upper_parameter = create(:parameter, code: 'Nox_Upper_Max', value: ".20")
    low_nox_parameter = create(:parameter, code: 'Low_NOx', value: "-.20")
    very_low_nox_parameter = create(:parameter, code: 'Very_Low_NOx', value: "-.25")
    high_co_nox_parameter = create(:parameter, code: 'High_CO_with_Low_NOx', value: ".80")

    Output.return_codes.each {|key, value|
      parameter = create(:parameter, code: value)
    }

    output = Output.process_input(input)
    assert_equal(Output.return_codes[:ok_engine_hours], output.engine_hours_code)
    assert_equal(Output.return_codes[:ok_engine_alternator_rpm_settings], output.engine_alternator_rpm_code)
    assert_equal(Output.return_codes[:ok_engine_alternator_hp_settings], output.engine_alternator_hp_code)
    assert_equal(nil, output.bank_balance_check_co2_percent_code)
    assert_equal(nil, output.bank_balance_check_co_code)
    assert_equal(nil, output.bank_balance_check_nox_code)
    assert_equal(Output.return_codes[:ok_co2_percentage_banks], output.co2_percent_left_bank_code)
    assert_equal(Output.return_codes[:ok_co_banks], output.co_left_bank_code)
    assert_equal(Output.return_codes[:ok_nox_banks], output.nox_left_bank_code)
    assert_equal(nil, output.co2_percent_right_bank_code)
    assert_equal(nil, output.co_right_bank_code)
    assert_equal(nil, output.nox_right_bank_code)
  end
end
