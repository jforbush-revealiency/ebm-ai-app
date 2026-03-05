class Company < ApplicationRecord
  has_many :locations, dependent: :destroy
  has_one :location
  accepts_nested_attributes_for :location, allow_destroy: true

  validates :code, presence: true
  validates_uniqueness_of :code
end
