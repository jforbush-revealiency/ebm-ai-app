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
Input.where(vehicle_id: nil).find_each do |input|
  next if input.vehicle_code.blank?
  v = Vehicle.find_by(code: input.vehicle_code)
  if v
    input.update_column(:vehicle_id, v.id)
    linked += 1
  end
end
puts "Linked: #{linked}"

puts "Updating statuses..."
warning_codes = %w[warning Warning high High]
caution_codes = %w[low Low caution Caution marginal]

Vehicle.find_each do |vehicle|
  inp = Input.where(vehicle_id: vehicle.id).order(submitted: :desc).first
  next unless inp
  out = Output.find_by(input_id: inp.id)
  next unless out

  all_codes = [
    out.co2_percent_left_bank_code,
    out.co2_percent_right_bank_code,
    out.co_left_bank_code,
    out.co_right_bank_code,
    out.nox_left_bank_code,
    out.nox_right_bank_code,
    out.bank_balance_check_co2_percent_code,
    out.bank_bala
