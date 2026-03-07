puts "Seeding engine config baselines..."

EngineConfig.find_each do |config|
  if config.co2_percent.nil? || config.co2_percent == 0
    config.update(co2_percent: 12.5)
    puts "  Updated: #{config.code} — CO2: 12.5%"
  end
end

updated = Input.where(test_type: nil).update_all(test_type: 'manual')
puts "  Set test_type = 'manual' on #{updated} existing input records"

puts "Linking test records to vehicles..."
linked = 0
not_found = 0

Input.where(vehicle_id: nil).find_each do |input|
  next if input.vehicle_code.blank?
  vehicle = Vehicle.find_by(code: input.vehicle_code)
  if vehicle
    input.update_column(:vehicle_id, vehicle.id)
    linked += 1
  else
    not_found +=
