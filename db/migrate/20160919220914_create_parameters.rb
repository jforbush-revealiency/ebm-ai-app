class CreateParameters < ActiveRecord::Migration[5.0]
  def change
    create_table :parameters do |t|
      t.string :code
      t.string :description
      t.string :value

      t.timestamps
    end
  end
end
