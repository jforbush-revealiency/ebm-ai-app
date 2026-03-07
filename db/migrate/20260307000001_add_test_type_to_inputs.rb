class AddTestTypeToInputs < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:inputs, :test_type)
      add_column :inputs, :test_type, :string, default: 'manual'
    end

    unless column_exists?(:inputs, :co2_savings_percent)
      add_column :inputs, :co2_savings_percent, :decimal, precision: 8, scale: 4
    end

    unless column_exists?(:inputs, :co2_gap_identified)
      add_column :inputs, :co2_gap_identified, :decimal, precision: 8, scale: 4
    end

    unless column_exists?(:inputs, :recommendation_acted_on)
      add_column :inputs, :recommendation_acted_on, :boolean, default: false
    end
  end
end
