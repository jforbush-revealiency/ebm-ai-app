class EngineConfig < ApplicationRecord
  belongs_to :engine
  has_many :vehicles, dependent: :restrict_with_error

  validates :code, presence: true
  validates_uniqueness_of :code, scope: :engine_id

  def co2_percent=(value)
    super(value / 100.0)
  end

  def co2_percent
    unless self[:co2_percent].blank?
     self[:co2_percent] * 100
    end
  end

  def co2_decimal
    self[:co2_percent]
  end

  def manufacturer_code 
    "#{engine.manufacturer.code}"
  end

  def engine_code 
    "#{engine.code}"
  end

  def drive_type_code
    "#{engine.drive_type.code}"
  end

  def default_test_percent_load
    test_percent_load.nil? ? 90 : test_percent_load
  end

  def default_test_rpm
    test_rpm.nil? ? 1750 : test_rpm
  end

  def default_test_boost_psi
    test_boost_psi.nil? ? 24 : test_boost_psi
  end

  def default_test_fuel_gallons_per_hour
    test_fuel_gallons_per_hour.nil? ? 30 : test_fuel_gallons_per_hour
  end

  def default_co2_plus_o2_percent
    co2_plus_o2_percent.nil? ? 18.3 : co2_plus_o2_percent
  end

  def default_rated_rpm
    rated_rpm.nil? ? 0 : rated_rpm 
  end

  def default_rated_hp
    rated_hp.nil? ? 0 : rated_hp
  end

  def as_json(options={})
    super(methods: [:engine_code, :manufacturer_code, :drive_type_code])
  end
end
