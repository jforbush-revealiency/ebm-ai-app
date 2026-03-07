namespace :fix do
  desc "Fix test_type to manual for all auto-imported inputs and reprocess outputs"
  task reprocess_outputs: :environment do
    puts "Updating test_type to manual for all auto-generated inputs..."
    updated = Input.where(auto_generated: true).update_all(test_type: 'manual')
    puts "Updated #{updated} inputs"

    puts "Reprocessing outputs..."
    success = 0
    errors  = []

    Input.where(auto_generated: true).find_each do |input|
      begin
        Output.where(input: input).destroy_all
        Output.process_input(input)
        success += 1
        print '.' if success % 50 == 0
      rescue => e
        errors << "Input #{input.id}: #{e.message}"
      end
    end

    puts "\n\n=== Reprocess Complete ==="
    puts "Reprocessed: #{success}"
    puts "Errors:      #{errors.count}"
    errors.first(20).each { |e| puts "  - #{e}" } if errors.any?
  end
end
