# Engine Config Baseline Seeds + Vehicle Link Repair

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

puts ""
puts "Linking test records to vehicles..."

linked = 0
skipped = 0
not_found = 0

Input.where(vehicle_id: nil).find_each do |input|
  next if input.vehicle_code.blank?

  vehicle = Vehicle.find_by(code: input.vehicle_code)

  if vehicle
    input.update_column(:vehicle_id, vehicle.id)
    linked += 1
  else
    not_found += 1
  end
end

puts "  Linked: #{linked}"
puts "  Already linked: #{skipped}"
puts "  Vehicle not found: #{not_found}"

puts ""
puts "Updating vehicle last diagnostic status..."

Vehicle.find_each do |vehicle|
  latest_input = Input.where(vehicle_id: vehicle.id)
                      .order(submitted: :desc)
                      .first

  next unless latest_input

  output = Output.find_by(input_id: latest_input.id)
  next unless output

  status = case output.overall_status
           when 'ok'       then 'in_spec'
           when 'caution'  then 'marginal'
           when 'warning'  then 'critical'
           else 'unknown'
           end

  vehicle.update_column(:last_diagnostic_status, status) rescue nil
  vehicle.update_column(:last_test_date, latest_input.submitted) rescue nil
  puts "  #{vehicle.code} → #{status}"
end

puts ""
puts "Done!"
```

Click **Commit changes**.

---

## Then Trigger Deploy on Render

Go to Render → **Manual Deploy** → **Deploy latest commit**

Watch the logs — you should see:
```
Linking test records to vehicles...
  Linked: 1816
  Vehicle not found: 0

Updating vehicle last diagnostic status...
  HT039 → critical
  OCP-001 → marginal
  ...
Done!
