class AddCompanyDieselFuel < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :average_diesel_fuel, :decimal, precision: 12, scale: 4
  end
end
