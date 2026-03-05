class AddParameterTypeToParameters < ActiveRecord::Migration[5.0]
  def change
    add_column :parameters, :parameter_type, :string
  end
end
