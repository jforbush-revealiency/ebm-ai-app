class CreateEngines < ActiveRecord::Migration[5.0]
  def change
    create_table :engines do |t|
      t.string :code
      t.string :description
      t.integer :manufacturer_id
      t.integer :drive_type_id

      t.timestamps
    end

    add_index :engines, :manufacturer_id
    add_index :engines, :drive_type_id
  end
end
