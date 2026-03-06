class TelematicsConfig < ApplicationRecord
  belongs_to :location
  belongs_to :vehicle, optional: true

  validates :min_load_percent,          presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :min_rpm,                   presence: true, numericality: { greater_than: 0 }
  validates :consistency_threshold_pct, presence: true, numericality: { greater_than: 0 }
  validates :test_frequency_hours,      presence: true, numericality: { greater_than: 0 }
  validates :daily_report_hour,         presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 24 }
  validates :sample_count,              presence: true, numericality: { greater_than_or_equal_to: 2 }
  validates :sample_interval_seconds,   presence: true, numericality: { greater_than: 0 }

  scope :enabled, -> { where(enabled: true) }

  FREQUENCY_OPTIONS = [
    ['Every 1 hour',   1.0],
    ['Every 2 hours',  2.0],
    ['Every 4 hours',  4.0],
    ['Every 6 hours',  6.0],
    ['Every 8 hours',  8.0],
    ['Every 12 hours', 12.0],
    ['Once per day',   24.0],
  ].freeze

  def frequency_label
    match = FREQUENCY_OPTIONS.find { |_, h| h == test_frequency_hours }
    match ? match[0] : "Every #{test_frequency_hours} hours"
  end
end
