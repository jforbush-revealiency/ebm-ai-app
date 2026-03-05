class Location < ApplicationRecord
  belongs_to :company
  has_many :inputs
  has_many :vehicles, dependent: :restrict_with_error
  has_many :users, dependent: :restrict_with_error

  validates :code, presence: true
  validates_uniqueness_of :code

  def company_code
    "#{company.code}"
  end

  def as_json(options={})
    super(methods: [:company_code])
  end
end
