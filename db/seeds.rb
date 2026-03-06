# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
parameters = Parameter.create([
  {code: "Engine_Parasitics_Max", value: "0.10", parameter_type: "decimal"},
  {code: "Horse_Power_Variances_Max", value: "0.005", parameter_type: "decimal"},
  {code: "Bank_Check_Max", value: "0.1", parameter_type: "decimal"},
  {code: "CO2_Percentage_Max", value: "0.0025", parameter_type: "decimal"},
  {code: "Nox_Upper_Max", value: "0.2", parameter_type: "decimal"},
  {code: "Nox_Lower_Max", value: "-0.2", parameter_type: "decimal"},
  {code: "Send_notification_emails_to", value: "admin@yourdomain.com", parameter_type: "string"},
  {code: "Send_notification_emails_from", value: "admin@yourdomain.com", parameter_type: "string"},
  {code: "Message_ok_engine_alternator_rpm_settings", value: "OK", parameter_type: "string"},
  {code: "Message_investigate_engine_alternator_rpm_settings", value: "Investigate Engine/Alternator RPM settings", parameter_type: "string"},
  {code: "Message_investigate_engine_alternator_parasitics", value: "Investigate Engine/Alternator Parasitics", parameter_type: "string"},
  {code: "Message_ok_engine_alternator_hp_settings", value: "OK", parameter_type: "string"},
  {code: "Message_check_engine_hp_settings", value: "Check Engine / HP Settings", parameter_type: "string"},
  {code: "Message_ok_bank_balance_check", value: "OK", parameter_type: "string"},
  {code: "Message_check_left_right_bank_performance", value: "Check Left/Right Bank Bank Performance", parameter_type: "string"},
  {code: "Message_ok_co2_percentage_banks", value: "OK", parameter_type: "string"},
  {code: "Message_low_co2_percentage", parameter_type: "textarea", 
   value: "Low CO2%\nEngine not receiving enough fuel, check fuel settings\nVerify drawing correct power - verify/reduce RPM settings"},
  {code: "Message_high_co2_percentage", parameter_type: "textarea", 
   value: "High CO2%\nEngine over fueled, reduce fuel input\nEngine is being lugged (verify/increase RPM)"},
  {code: "Message_ok_co_banks", value: "OK", parameter_type: "string"},
  {code: "Message_high_co", parameter_type: "textarea", 
   value: "High CO\nToo much fuel for the available air - engine overfueled\nCheck air flow through turbo, turbo boost, waste gate\nCheck oil consumption (internal combustion issues-rings, liners, etc.)\nCheck turbo boost against standards (ECM)"},
  {code: "Message_ok_nox_banks", value: "OK", parameter_type: "string"},
  {code: "Message_high_nox", parameter_type: "textarea", value: "High NOx\nCombustion chamber temperature too high\nCheck inlet air temperature output (ECM)\n"},
  {code: "Message_low_nox", parameter_type: "textarea", value: "Low NOx\nCombustion chamber temperature too low\nCheck exhaust gas temperatures against standards (ECM)\nCheck for blocked after cooler\nCheck for low turbo boost (ECM)\nCheck for restriction in intake\nCheck for waste gate malfunction"},
])

load Rails.root.join('db/seeds/redmond_ht4.rb')
