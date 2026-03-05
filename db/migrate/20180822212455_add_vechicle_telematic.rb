class AddVechicleTelematic < ActiveRecord::Migration[5.0]
  def change
    add_column :vehicles, :telematic, :boolean, default: 0, null: false
  end
end
