class Input < ApplicationRecord
  belongs_to :location
  belongs_to :vehicle
  belongs_to :user
  has_one :output, dependent: :destroy

  validates :location_id, presence: true
  validates :vehicle_id, presence: true
  validates :engine_hours, presence: true
  validates :engine_rpm, presence: true
  validates :engine_hp, presence: true, unless: :auto_generated?
  validates :left_bank_co2_percent, presence: true
  validates :left_bank_co, presence: true, unless: :auto_generated?
  validates :left_bank_nox, presence: true
  validates_presence_of :right_bank_co2_percent, unless: Proc.new {|input| input.vehicle.engine_config.engine.is_single_stack} 
  validates_presence_of :right_bank_co, unless: Proc.new {|input| input.vehicle.engine_config.engine.is_single_stack} 
  validates_presence_of :right_bank_nox, unless: Proc.new {|input| input.vehicle.engine_config.engine.is_single_stack} 

  validates_associated :user
  validates_associated :location
  validates_associated :vehicle

  def left_bank_co2_percent=(value)
    super(value / 100.0)
  end

  def left_bank_co2_percent
    self[:left_bank_co2_percent] * 100 unless self[:left_bank_co2_percent].nil?
  end

  def left_bank_co2_decimal
    self[:left_bank_co2_percent]
  end

  def right_bank_co2_percent=(value)
    if value.present?
      super(value / 100.0)
    else
      super(0.00 / 100.0)
    end
  end

  def right_bank_co2_percent
    self[:right_bank_co2_percent] * 100 unless self[:right_bank_co2_percent].nil?
  end

  def right_bank_co2_decimal
    self[:right_bank_co2_percent]
  end

  def company_code 
    "#{location.company.code}"
  end

  def manufacturer_code 
    "#{vehicle.engine_config.engine.manufacturer.code}"
  end

  def engine_code 
    "#{vehicle.engine_config.engine.code}"
  end

  def is_single_stack 
    "#{vehicle.engine_config.engine.is_single_stack}"
  end

  def drive_type 
    "#{vehicle.engine_config.engine.drive_type.code}"
  end

  def commit(current_user, location, submitted=nil)
    self.user = current_user
    self.location = location
    self.vehicle = location.vehicles.find(self.vehicle_id)
    self.company_code = location.company.code
    self.location_code = location.code
    self.vehicle_code = vehicle.code

    if self.new_record?
      self.submitter_first_name = current_user.first_name
      self.submitter_last_name = current_user.last_name
      self.submitter_email = current_user.email
      if submitted.nil? 
        self.submitted = DateTime.now
      else
        self.submitted = submitted
      end
    else
      self.updated_by_first_name = current_user.first_name
      self.updated_by_last_name = current_user.last_name
      self.updated_by_email = current_user.email
    end

    return self.save!
  end

  def self.to_csv(inputs)
    title_row = ["Vehicle #", "Vehicle Model", "Vehicle Serial #", 
              "Engine Make", "Engine Hours", "Engine Model", "Engine RPM",
    "Alternator RPM", "Engine HP", "Alternator HP", "Left-CO2%", 
    "Left-CO", "Left-NOx", "Right-CO2%", "Right-CO", 
    "Right-NOX", "Location", "Company", "Test Date"]
    Time.use_zone("Mountain Time (US & Canada)") do
      CSV.generate do |csv|
        csv << title_row 
        inputs.each do |input|
        submitted = input.submitted.in_time_zone.strftime("%Y-%m-%d")
          csv << [input.vehicle.code, input.vehicle.model_number, input.vehicle.serial_number,
            input.vehicle.manufacturer_code, input.engine_hours, input.engine_code, input.engine_rpm,
            input.alternator_rpm, input.engine_hp, input.alternator_hp, input.left_bank_co2_percent, 
            input.left_bank_co, input.left_bank_nox, input.right_bank_co2_percent, input.right_bank_co, 
            input.right_bank_nox, input.location_code, input.company_code, submitted]
        end
      end
    end
  end

  def as_json(options={})
    super(methods: [:company_code, :manufacturer_code, :engine_code, :drive_type, :is_single_stack ])
  end
end
