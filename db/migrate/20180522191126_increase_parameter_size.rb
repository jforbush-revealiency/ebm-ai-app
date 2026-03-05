class IncreaseParameterSize < ActiveRecord::Migration[5.0]
  def up
    change_column :parameters, :value, :string, :limit => 1000 
  end

  def down
    change_column :parameters, :value, :string, :limit => 255 
  end
end

