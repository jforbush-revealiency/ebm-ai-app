class AddExtremelyHighCo < ActiveRecord::Migration[5.0]
  def up
    Parameter.create(
    {code: "Message_extremely_high_co", parameter_type: "textarea", 
   value: "Warning-Extremely High CO Concentration-Check Injector Settings\nWarning-Extremely High CO Concentration-Check fuel calibration\nWarning - check engine calibration file compared to latest OEM calibration file for the engine and vehicle"})
  end
  def down
    Parameter.where(code: "Message_extremely_high_co").destroy_all
  end
end
