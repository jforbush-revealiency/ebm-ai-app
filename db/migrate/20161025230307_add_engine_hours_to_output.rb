class AddEngineHoursToOutput < ActiveRecord::Migration[5.0]
  def up
    add_column :outputs, :engine_hours_code, :string
    add_column :outputs, :engine_hours_message, :string

    parameters = Parameter.create([
      {code: "Message_ok_engine_hours", value: "OK", parameter_type: "string"},
      {code: "Message_investigate_engine_hours", value: "Investigate engine hours. Previous engine hours: %s", parameter_type: "string"},
    ])
  end
  def down
    remove_column :outputs, :engine_hours_code, :string
    remove_column :outputs, :engine_hours_message, :string
    Parameter.where(code: "Message_ok_engine_hours").destroy_all
    Parameter.where(code: "Message_investigate_engine_hours").destroy_all
  end
end
