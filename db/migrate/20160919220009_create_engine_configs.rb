class CreateEngineConfigs < ActiveRecord::Migration[5.0]
  def change
    create_table :engine_configs do |t|
      t.string :code
      t.string :description
      t.decimal :co2_percent
      t.decimal :co
      t.decimal :nox
      t.integer :engine_id

      t.timestamps
    end

    add_index :engine_configs, :engine_id
  end
end
