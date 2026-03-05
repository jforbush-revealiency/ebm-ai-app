class CreateVehicles < ActiveRecord::Migration[5.0]
  def change
    create_table :vehicles do |t|
      t.string :code
      t.string :description
      t.string :model_number
      t.string :serial_number
      t.integer :engine_config_id
      t.integer :location_id

      t.timestamps
    end

    add_index :vehicles, :location_id
    add_index :vehicles, :engine_config_id
  end
end
