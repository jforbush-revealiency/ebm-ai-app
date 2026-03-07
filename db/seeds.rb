puts "Seeding baselines..."
EngineConfig.find_each do |config|
  if config.co2_percent.nil? || config.co2_percent == 0
    config.update(co2_percent: 12.5)
    puts "  Updated: #{config.code}"
  end
end
Input.where(test_type: nil).update_all(test_type: 'manual')
puts "Linking inputs to vehicles..."
linked = 0
missing = 0
Input.where(vehicle_id: nil).find_each do |input|
  next if input.vehicle_code.blank?
  v = Vehicle.find_by(code: input.vehicle_code)
  if v
    input.update_column(:vehicle_id, v.id)
    linked += 1
  else
    missing += 1
  end
end
puts "Linked: #{linked}, Missing: #{missing}"
puts "Updating statuses..."
Vehicle.find_each do |vehicle|
  inp = Input.where(vehicle_id: vehicle.id).order(submitted: :desc).first
  next unless inp
  out = Output.find_by(input_id: inp.id)
  next unless out
  s = out.overall_status == 'ok' ? 'in_spec' : out.overall_status == 'caution' ? 'marginal' : 'critical'
  vehicle.update_column(:last_diagnostic_status, s) rescue nil
  vehicle.update_column(:last_test_date, inp.submitted) rescue nil
  puts "  #{vehicle.code} => #{s}"
end
puts "Done!"
