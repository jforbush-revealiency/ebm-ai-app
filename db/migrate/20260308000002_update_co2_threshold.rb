class UpdateCo2Threshold < ActiveRecord::Migration[7.1]
  def up
    Parameter.where(code: 'High_CO2_Percentage').update_all(value: '0.25')
    Parameter.where(code: 'Elevated_CO2_Percentage').update_all(value: '0.10')
    Parameter.where(code: 'Low_NOx').update_all(value: '-0.25')
    Parameter.where(code: 'Very_Low_NOx').update_all(value: '-0.35')
  end

  def down
    Parameter.where(code: 'High_CO2_Percentage').update_all(value: '0.05')
    Parameter.where(code: 'Elevated_CO2_Percentage').update_all(value: '0.0025')
    Parameter.where(code: 'Low_NOx').update_all(value: '-0.20')
    Parameter.where(code: 'Very_Low_NOx').update_all(value: '-0.25')
  end
end
