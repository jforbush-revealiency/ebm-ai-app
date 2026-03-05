class AddRatedRpmRatedHp < ActiveRecord::Migration[5.0]
  def change
    add_column :engine_configs, :rated_rpm, :decimal, precision: 12, scale: 4
    add_column :engine_configs, :rated_hp, :decimal, precision: 12, scale: 4
  end
end
