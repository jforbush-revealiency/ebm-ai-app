class Vehicle < ApplicationRecord
  belongs_to :engine_config
  belongs_to :location
  has_many :inputs

  validates :code, presence: true
  validates_uniqueness_of :code, scope: :location_id

  def previous_engine_hours(current_input)
    previous_input = self.inputs.where("id < ?", current_input.id).order("id DESC").limit(1).first
    engine_hours = 0.0
    unless previous_input.nil?
      engine_hours = previous_input.engine_hours
    end
    engine_hours
  end

  def company_code 
    "#{location.company.code}"
  end

  def location_code 
    "#{location.code}"
  end

  def manufacturer_code 
    "#{engine_config.engine.manufacturer.code}"
  end

  def engine_code 
    "#{engine_config.engine.code}"
  end

  def engine_config_code 
    "#{engine_config.code}"
  end

  def drive_type 
    "#{engine_config.engine.drive_type.code}"
  end

  def is_single_stack 
    "#{engine_config.engine.is_single_stack}"
  end

  def as_json(options={})
    super(methods: [:company_code, :location_code, :manufacturer_code, :engine_code, 
                    :engine_config_code, :drive_type, :is_single_stack, :folder_code, 
                    :estimated_annual_vehicle_hours, :telematic])
  end
end
