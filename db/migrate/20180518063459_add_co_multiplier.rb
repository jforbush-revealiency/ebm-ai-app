class AddCoMultiplier < ActiveRecord::Migration[5.0]
  def up
    Parameter.create(
    {code: "CO_Multiplier", value: "3", parameter_type: "decimal"})
  end
  def down
    Parmeter.where(code: "CO_Multiplier").destroy_all
  end
end
