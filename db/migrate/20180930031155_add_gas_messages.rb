class AddGasMessages < ActiveRecord::Migration[5.0]
  def up
    Parameter.create(
      {code: "Message_rated_rpm_limit_exceeded", parameter_type: "textarea", 
       value: "Check Alternator settings or torque convertor stall point."})

    Parameter.create({code: "Rated_RPM_Max", value: "0.10", parameter_type: "decimal"})

    Parameter.create(
      {code: "Message_investigate_engine_or_drivetrain_alternator_parasitics", parameter_type: "textarea", 
       value: "Investigate engine or drivetrain alternator parasitics"})
    Parameter.create({code: "Rated_RPM_Min", value: "-0.20", parameter_type: "decimal"})

    Parameter.create(
      {code: "Message_elevated_co", parameter_type: "textarea", 
       value: "Caution - Elevated CO - Too much fuel for the available air\nCheck air filters\nCheck for leaks between turbo and intake manifold\nCheck for exhaust leaks before turbo"})
    Parameter.create({code: "Elevated_CO", value: "2", parameter_type: "decimal"})

    Parameter.where(code: "CO_Multiplier").destroy_all
    #Parameter.where(code: "Message_high_co").destroy_all

    Parameter.create(
      {code: "Message_high_co", parameter_type: "textarea", 
       value: "Warning - High CO - Too much fuel for the available air\nCheck air flow through turbo, turbo boost, wastegate\nCheck oil consumption (internal combustion issues-rings, liners, etc.)\nCheck turbo boost against standards\nCaution - Elevated CO - Too much fuel for the available air\nCheck air filters\nCheck for leaks between turbo and intake manifold\nCheck for exhaust leaks before turbo"})
    Parameter.create({code: "High_CO", value: "3", parameter_type: "decimal"})

    Parameter.create(
      {code: "Message_high_co_with_low_nox", parameter_type: "textarea", 
       value: "Warning - High CO - Too much fuel for the available air\nCheck air flow through turbo, turbo boost, wastegate\nCheck oil consumption (internal combustion issues-rings, liners, etc.)\nCheck turbo boost against standards\nCheck injection timing\nCaution - Elevated CO - Too much fuel for the available air\nCheck air filters\nCheck for leaks between turbo and intake manifold\nCheck for exhaust leaks before turbo"})
    Parameter.create({code: "High_CO_with_Low_NOx", value: ".80", parameter_type: "decimal"})

    Parameter.where(code: "CO2_Percentage_Max").destroy_all

    Parameter.create(
      {code: "Message_elevated_co2_percentage", parameter_type: "textarea", 
       value: "Caution - Elevated CO2% - Engine over fueled\nCheck air intake system\nCheck air filters\nEngine is being lugged (verify/increase RPM or decrease load) as appropriate"})
    Parameter.create({code: "Elevated_CO2_Percentage", value: ".0025", parameter_type: "decimal"})

    Parameter.create(
      {code: "Message_high_co2_percentage", parameter_type: "textarea", 
       value: "Warning - High CO2% - Engine over fueled\nCheck valve train adjustment\nCheck injector settings\nVerify engine calibration\nCaution - Elevated CO2% - Engine over fueled\nCheck air intake system\nCheck air filters\nEngine is being lugged (verify/increase RPM or decrease load) as appropriate"})
    Parameter.create({code: "High_CO2_Percentage", value: ".05", parameter_type: "decimal"})

    #Parameter.where(code: "Message_low_nox").destroy_all
    Parameter.where(code: "Nox_Lower_Max").destroy_all

    Parameter.create(
      {code: "Message_low_nox", parameter_type: "textarea", 
       value: "Caution - Low NOx - Combustion chamger temperature too low\nCheck exhaust gas temperatures against standards\nCheck for low turbo boost\nCheck injection timing\nCheck for leaks between turbo and intake manifold\nCheck for exhaust leaks before turbo"})
    Parameter.create({code: "Low_NOx", value: "-.20", parameter_type: "decimal"})

    Parameter.create(
      {code: "Message_very_low_nox", parameter_type: "textarea", 
       value: "Warning - Low NOx - Combustion chamber temperature too low\nCheck for blocked after cooler\nCheck for restriction in intake\nCheck air filters\nCheck for waste gate malfunction\nCaution - Low NOx - Combustion chamger temperature too low\nCheck exhaust gas temperatures against standards\nCheck for low turbo boost\nCheck injection timing\nCheck for leaks between turbo and intake manifold\nCheck for exhaust leaks before turbo"})
    Parameter.create({code: "Very_Low_NOx", value: "-.25", parameter_type: "decimal"})
  end
  def down
    Parameter.where(code: "Message_rated_rpm_limit_exceeded").destroy_all
    Parameter.where(code: "Rated_RPM_Max").destroy_all

    Parameter.where(code: "Message_investigate_engine_or_drivetrain_alternator_parasitics").destroy_all
    Parameter.where(code: "Rated_RPM_Min").destroy_all

    Parameter.where(code: "Message_elevated_co").destroy_all
    Parameter.where(code: "Elevated_CO").destroy_all

    Parameter.where(code: "Message_high_co").destroy_all
    Parameter.where(code: "High_CO").destroy_all

    Parameter.where(code: "Message_high_co_with_low_nox").destroy_all
    Parameter.where(code: "High_CO_with_Low_NOx").destroy_all

    Parameter.where(code: "Message_elevated_co2_percentage").destroy_all
    Parameter.where(code: "Elevated_CO2_Percentage").destroy_all

    Parameter.where(code: "Message_high_co2_percentage").destroy_all
    Parameter.where(code: "High_CO2_Percentage").destroy_all

    Parameter.where(code: "Message_low_nox").destroy_all
    Parameter.where(code: "Low_NOx").destroy_all

    Parameter.where(code: "Message_very_low_nox").destroy_all
    Parameter.where(code: "Very_Low_NOx").destroy_all
  end
end
