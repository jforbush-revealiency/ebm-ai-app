# Engine Config Baseline Seeds
# Sets rated CO2% baseline for known engine configurations

puts "Seeding engine config baselines..."

EngineConfig.find_each do |config|
  if config.co2_percent.nil? || config.co2_percent == 0
    config.update(co2_percent: 12.5)
    puts "  Updated: #{config.code} — CO2: 12.5%"
  end
end

# Update all existing inputs to have test_type = 'manual'
updated = Input.where(test_type: nil).update_all(test_type: 'manual')
puts "  Set test_type = 'manual' on #{updated} existing input records"

puts "Done!"
