#!/usr/bin/env bash
set -o errexit

bundle config set frozen false
bundle lock --add-platform x86_64-linux
bundle install

bundle exec rails db:migrate

# Run seed only if TelematicsConfig table is empty
bundle exec rails runner "
  if TelematicsConfig.count == 0
    puts 'Running seed...'
    load Rails.root.join('db/seeds/redmond_ht4.rb')
  else
    puts 'Seed already run — skipping'
  end
"

# Import, process, and report — only if not already done
STAT_COUNT=$(bundle exec rails runner "puts VehicleStat.count" 2>/dev/null | tail -1)
if [ "$STAT_COUNT" = "0" ]; then
  echo "Importing vehicle stats..."
  bundle exec rake telematics:import_stats FILE=tmp/import/redmond_ht4_feb2018.csv VEHICLE=redmond_ht4
else
  echo "Vehicle stats already imported ($STAT_COUNT rows) — skipping"
fi

TEST_COUNT=$(bundle exec rails runner "puts ValidEmissionTest.count" 2>/dev/null | tail -1)
if [ "$TEST_COUNT" = "0" ]; then
  echo "Processing ISO 8178 windows..."
  bundle exec rake telematics:process_iso8178 VEHICLE=redmond_ht4
else
  echo "Valid emission tests already exist ($TEST_COUNT) — skipping"
fi

REPORT_COUNT=$(bundle exec rails runner "puts Input.where(auto_generated: true).count" 2>/dev/null | tail -1)
if [ "$REPORT_COUNT" = "0" ]; then
  echo "Generating daily reports..."
  bundle exec rake telematics:generate_daily_reports VEHICLE=redmond_ht4
else
  echo "Daily reports already exist ($REPORT_COUNT) — skipping"
fi
