class Engine < ApplicationRecord

  belongs_to :manufacturer
  belongs_to :drive_type

  has_many :engine_configs, dependent: :restrict_with_error

  validates :code, presence: true
  validates_uniqueness_of :code, scope: :manufacturer_id

  def manufacturer_code 
    "#{manufacturer.code}"
  end

  def drive_type_code 
    "#{drive_type.code}"
  end

  def as_json(options={})
    super(methods: [:manufacturer_code, :drive_type_code])
  end
end
