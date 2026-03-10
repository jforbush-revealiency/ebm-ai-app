class CleanupDuplicateLocations < ActiveRecord::Migration[7.1]
  def up
    # Remove duplicate locations that have the same code as an older record
    # Keep the original (lowest ID), delete the newer duplicate
    duplicates = Location.select(:code).group(:code).having("COUNT(*) > 1").pluck(:code)

    duplicates.each do |code|
      records = Location.where(code: code).order(:id)
      original = records.first
      dupes = records.offset(1)

      Rails.logger.info "Cleaning duplicate location code='#{code}': keeping ID #{original.id}, removing IDs #{dupes.pluck(:id).join(', ')}"

      # Move any vehicles pointing to duplicates back to the original
      dupes.each do |dupe|
        Vehicle.where(location_id: dupe.id).update_all(location_id: original.id)
        dupe.destroy!
      end
    end

    # Fix company assignments for the original locations
    # Morocco -> OCP (company code 'ocp')
    ocp = Company.find_by(code: 'ocp')
    if ocp
      loc = Location.find_by(code: 'morocco')
      loc&.update_columns(company_id: ocp.id, description: 'Morocco')
    end

    # TTJV-Mongolia -> OEM Asia Pilot (company code 'oem-asia-pilot')
    oem = Company.find_by(code: 'oem-asia-pilot')
    if oem
      loc = Location.find_by(code: 'ttjv-mongolia')
      loc&.update_columns(company_id: oem.id, description: 'TTJV-Mongolia')
    end

    # TestLocation -> TestCo (company code 'testco')
    testco = Company.find_by(code: 'testco')
    if testco
      loc = Location.find_by(code: 'testlocation')
      loc&.update_columns(company_id: testco.id, description: 'TestLocation')
    end

    # Delete orphaned "OEM Pilots" company (code 'OEM Pilot') if it has no locations left
    oem_pilot = Company.find_by(code: 'OEM Pilot')
    if oem_pilot && oem_pilot.locations.count == 0
      oem_pilot.destroy!
      Rails.logger.info "Deleted orphaned company 'OEM Pilots' (ID #{oem_pilot.id})"
    end

    Rails.logger.info "Duplicate location cleanup complete"
  end

  def down
    # Data migration — not reversible
  end
end
