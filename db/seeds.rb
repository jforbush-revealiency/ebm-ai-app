# Engine Config Baseline Seeds
# Sets rated CO2%, CO, and NOx baselines for known engine configurations

puts "Seeding engine config baselines..."

baseline_updates = [
  { co2_target: 12.5, co_target: 500,  nox_target: 800  },  # typical diesel baseline
]

EngineConfig.find_each do |config|
  if config.co2_percent.nil? || config.co2_percent == 0
    config.update(
      co2_percent:     12.5,
      co_target:       500.0,
      nox_target:      800.0
    )
    puts "  Updated: #{config.code} — CO2: 12.5%, CO: 500, NOx: 800"
  end
end

# Update all existing inputs to have test_type = 'manual'
updated = Input.where(test_type: nil).update_all(test_type: 'manual')
puts "  Set test_type = 'manual' on #{updated} existing input records"

puts "Done!"
