class DriveType < ApplicationRecord
  has_many :engines, dependent: :restrict_with_error
  validates :code, presence: true
  validates :code, uniqueness: { case_sensitive: false }
end
