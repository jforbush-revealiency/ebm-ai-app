#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec rails db:migrate

# Run seed only if TelematicsConfig table is empty (safe to run on every deploy)
bundle exec rails runner "
  if TelematicsConfig.count == 0
    puts 'Running seed...'
    load Rails.root.join('db/seeds/redmond_ht4.rb')
  else
    puts 'Seed already run — skipping'
  end
"

# Import Redmond HT4 CSV if vehicle_stats table is empty
bundle exec rails runner "
  if VehicleStat.count == 0
    puts 'Importing vehicle stats...'
    ENV['FILE']    = 'tmp/import/redmond_ht4_feb2018.csv'
    ENV['VEHICLE'] = 'redmond_ht4'
    Rake::Task['telematics:import_stats'].invoke
  else
    puts 'Vehicle stats already imported — skipping'
  end
"

# Process ISO 8178 windows if no valid emission tests exist yet
bundle exec rails runner "
  if ValidEmissionTest.count == 0
    puts 'Processing ISO 8178 windows...'
    ENV['VEHICLE'] = 'redmond_ht4'
    Rake::Task['telematics:process_iso8178'].invoke
  else
    puts 'Valid emission tests already exist — skipping'
  end
"

# Generate daily reports if none exist yet
bundle exec rails runner "
  if Input.where(auto_generated: true).count == 0
    puts 'Generating daily reports...'
    ENV['VEHICLE'] = 'redmond_ht4'
    Rake::Task['telematics:generate_daily_reports'].invoke
  else
    puts 'Daily reports already exist — skipping'
  end
"
