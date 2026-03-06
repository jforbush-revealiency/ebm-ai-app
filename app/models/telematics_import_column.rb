class TelematicsImportColumn < ApplicationRecord
  belongs_to :location
  belongs_to :vehicle, optional: true

  validates :column_map, presence: true

  # Returns only the enabled columns as a csv_col => db_col hash
  def enabled_map
    column_map
      .select { |_, cfg| cfg['enabled'] == true && cfg['db_column'].present? }
      .transform_values { |cfg| cfg['db_column'] }
  end
end
