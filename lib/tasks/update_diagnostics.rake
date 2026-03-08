namespace :update do
  desc "Recalculate and update last_diagnostic_status for all vehicles"
  task diagnostic_statuses: :environment do
    puts "Updating diagnostic statuses for all vehicles..."
    updated = 0
    skipped = 0

    Vehicle.find_each do |vehicle|
      # Get most recent input by ID (highest ID = most recent import)
      input = vehicle.inputs.order(id: :desc).first
      if input.nil?
        skipped += 1
        next
      end

      begin
        status = DiagnosticService.calculate_status(input)
        vehicle.update_column(:last_diagnostic_status, status)
        updated += 1
        print "."
      rescue => e
        puts "\nError on vehicle #{vehicle.id}: #{e.message}"
        skipped += 1
      end
    end

    puts "\nDone. Updated: #{updated}, Skipped: #{skipped}"
  end
end
