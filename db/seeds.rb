puts "Seeding baselines..."
EngineConfig.find_each do |c|
  c.update(co2_percent: 12.5) if c.co2_percent.nil? || c.co2_percent == 0
end
Input.where(test_type: nil).update_all(test_type: 'manual')
puts "Linking inputs..."
linked = 0
Input.where(vehicle_id: nil).find_each do |i|
  next if i.vehicle_code.blank?
  v = Vehicle.find_by(code: i.vehicle_code)
  next unless v
  i.update_column(:vehicle_id, v.id)
  linked += 1
end
puts "Linked: #{linked}"
puts "Updating statuses..."
Vehicle.find_each do |v|
  i = Input.where(vehicle_id: v.id).order(submitted: :desc).first
  next unless i
  o = Output.find_by(input_id: i.id)
  next unless o
  codes = "#{o.co2_percent_left_bank_code} #{o.co2_percent_right_bank_code} #{o.co_left_bank_code} #{o.co_right_bank_code} #{o.nox_left_bank_code} #{o.nox_right_bank_code}"
  s = codes.match?(/warning|Warning|high|High/) ? 'critical' : codes.match?(/low|Low|caution|Caution/) ? 'marginal' : 'in_spec'
  v.update_column(:last_diagnostic_status, s) rescue nil
  v.update_column(:last_test_date, i.submitted) rescue nil
  puts "  #{v.code} => #{s}"
end
puts "Done!"
