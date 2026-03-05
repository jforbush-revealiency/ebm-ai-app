class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.string :code
      t.string :description
      t.boolean :attainment
      t.integer :company_id

      t.timestamps
    end

    add_index :locations, :company_id
  end
end
