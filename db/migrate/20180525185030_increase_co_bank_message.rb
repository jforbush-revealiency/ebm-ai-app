class IncreaseCoBankMessage < ActiveRecord::Migration[5.0]
  def up
    change_column :outputs, :co_left_bank_message, :string, :limit => 1000 
    change_column :outputs, :co_right_bank_message, :string, :limit => 1000 
  end

  def down
    change_column :outputs, :co_left_bank_message, :string, :limit => 255 
    change_column :outputs, :co_right_bank_message, :string, :limit => 255 
  end
end
