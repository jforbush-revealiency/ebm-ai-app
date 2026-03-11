class ReconcileAllData < ActiveRecord::Migration[7.1]
  def up
    Rails.logger.info "=== Starting full data reconciliation ==="

    # =========================================================================
    # 1. MANUFACTURERS — ensure all exist
    # =========================================================================
    manufacturers = {}
    [
      ['caterpillar', 'Caterpillar'],
      ['cummins', 'Cummins'],
      ['mtu', 'MTU'],
      ['emd', 'EMD'],
      ['john-deere', 'John Deere'],
      ['komatsu', 'Komatsu'],
    ].each do |code, name|
      m = Manufacturer.find_or_create_by!(code: code) do |mfr|
        mfr.description = name
      end
      manufacturers[code] = m
      Rails.logger.info "Manufacturer: #{name} (ID #{m.id})"
    end

    # =========================================================================
    # 2. ENGINES — ensure all exist with correct single_stack flag
    # =========================================================================
    engines = {}
    [
      # [code, description, manufacturer_code, is_single_stack]
      ['3508', 'Caterpillar 3508', 'caterpillar', true],
      ['3516', 'Caterpillar 3516', 'caterpillar', false],
      ['C175', 'Caterpillar C175', 'caterpillar', false],
      ['C18', 'Caterpillar C18', 'caterpillar', true],
      ['C27', 'Caterpillar C27', 'caterpillar', false],
      ['K2000', 'Cummins K2000', 'cummins', false],
      ['QSK50', 'Cummins QSK50', 'cummins', false],
      ['QSK60', 'Cummins QSK60', 'cummins', false],
      ['QSK78', 'Cummins QSK78', 'cummins', false],
      ['16-645F3B', 'EMD 16-645F3B', 'emd', true],
      ['606', 'John Deere 606', 'john-deere', true],
      ['16V-4000', 'MTU 16V-4000', 'mtu', false],
      ['16V-4000-T4', 'MTU 16V-4000 Tier4', 'mtu', false],
    ].each do |code, desc, mfr_code, single|
      e = Engine.find_or_initialize_by(code: code)
      e.description = desc
      e.manufacturer_id = manufacturers[mfr_code].id
      e.is_single_stack = single
      e.save!
      engines[code] = e
      Rails.logger.info "Engine: #{desc} (ID #{e.id}, single_stack=#{single})"
    end

    # =========================================================================
    # 3. ENGINE CONFIGS — one per engine variant with correct baselines
    # =========================================================================
    configs = {}
    [
      # [config_code, description, engine_code, co2%, co, nox, rpm, hp]
      ['3508-DRILL', 'Cat 3508 Drill', '3508', 7.0, 250.0, 900.0, 1800, 688],
      ['3516-HT', 'Cat 3516 Haul Truck', '3516', 6.9, 117.0, 522.0, 1600, 2500],
      ['C175-HT', 'Cat C175 Haul Truck', 'C175', 7.7, 363.0, 639.0, 1800, 3000],
      ['C18-GEN', 'Cat C18 Generator', 'C18', 8.4, 972.0, 731.0, 2000, 320],
      ['C27-HT', 'Cat C27 Haul Truck', 'C27', 10.3, 507.0, 507.0, 1800, 800],
      ['K2000-HT', 'Cummins K2000 Haul Truck', 'K2000', 9.9, 477.0, 912.0, 1900, 1750],
      ['QSK50-HT', 'Cummins QSK50 Haul Truck', 'QSK50', 9.4, 342.0, 531.0, 1900, 1750],
      ['QSK60-HT', 'Cummins QSK60 Haul Truck', 'QSK60', 9.2, 300.0, 1020.0, 1909, 2300],
      ['QSK78-HT', 'Cummins QSK78 Haul Truck', 'QSK78', 8.7, 334.0, 576.0, 1800, 3040],
      ['16-645F3B-LOCO', 'EMD 16-645F3B Locomotive', '16-645F3B', 6.4, 509.0, 659.0, 953, 3200],
      ['606-GEN', 'John Deere 606 Generator', '606', 10.5, 102.0, 1036.0, 1800, 150],
      ['16V4000-HT', 'MTU 16V-4000 Haul Truck', '16V-4000', 8.5, 200.0, 800.0, 1910, 2580],
      ['16V4000-T4-HT', 'MTU 16V-4000 Tier4 Haul Truck', '16V-4000-T4', 8.4, 185.0, 479.0, 1971, 2315],
    ].each do |code, desc, engine_code, co2, co, nox, rpm, hp|
      engine = engines[engine_code]
      ec = EngineConfig.find_or_initialize_by(code: code)
      ec.description = desc
      ec.engine_id = engine.id
      ec.co2_percent = co2
      ec.co = co
      ec.nox = nox
      ec.rated_rpm = rpm
      ec.rated_hp = hp
      ec.save!
      configs[code] = ec
      Rails.logger.info "EngineConfig: #{desc} (ID #{ec.id}) — CO2:#{co2}% CO:#{co} NOx:#{nox} RPM:#{rpm} HP:#{hp}"
    end

    # =========================================================================
    # 4. MERGE DUPLICATE ENGINE CONFIGS — move vehicles to canonical config
    # =========================================================================
    # Find any old QSK60 configs and merge into our canonical one
    canonical_qsk60 = configs['QSK60-HT']
    EngineConfig.where("code LIKE '%QSK60%' OR code LIKE '%qsk60%'").where.not(id: canonical_qsk60.id).each do |old|
      count = Vehicle.where(engine_config_id: old.id).count
      Vehicle.where(engine_config_id: old.id).update_all(engine_config_id: canonical_qsk60.id)
      Rails.logger.info "Merged old QSK60 config ID #{old.id} (#{old.code}) → #{canonical_qsk60.id}. Moved #{count} vehicles."
      old.destroy! if Vehicle.where(engine_config_id: old.id).count == 0
    end

    # Merge old MTU 16V-4000 configs (non-Tier4)
    canonical_mtu = configs['16V4000-HT']
    EngineConfig.where("(code LIKE '%16V%4000%' OR code LIKE '%16v%4000%') AND code NOT LIKE '%T4%' AND code NOT LIKE '%Tier4%'").where.not(id: canonical_mtu.id).each do |old|
      count = Vehicle.where(engine_config_id: old.id).count
      Vehicle.where(engine_config_id: old.id).update_all(engine_config_id: canonical_mtu.id)
      Rails.logger.info "Merged old MTU config ID #{old.id} (#{old.code}) → #{canonical_mtu.id}. Moved #{count} vehicles."
      old.destroy! if Vehicle.where(engine_config_id: old.id).count == 0
    end

    # Merge old 606 configs
    canonical_606 = configs['606-GEN']
    EngineConfig.where("code LIKE '%606%'").where.not(id: canonical_606.id).each do |old|
      count = Vehicle.where(engine_config_id: old.id).count
      Vehicle.where(engine_config_id: old.id).update_all(engine_config_id: canonical_606.id)
      Rails.logger.info "Merged old 606 config ID #{old.id} (#{old.code}) → #{canonical_606.id}. Moved #{count} vehicles."
      old.destroy! if Vehicle.where(engine_config_id: old.id).count == 0
    end

    # =========================================================================
    # 5. LOCATIONS — create Hazard for TestCo
    # =========================================================================
    testco = Company.find_by("code LIKE '%testco%' OR code LIKE '%TestCo%'")
    if testco
      hazard = Location.find_or_create_by!(code: 'hazard') do |l|
        l.description = 'Hazard'
        l.company_id = testco.id
        l.attainment = false
      end
      Rails.logger.info "Location: Hazard (ID #{hazard.id}) under TestCo (ID #{testco.id})"

      # Ensure Black Thunder location exists under TestCo for TestCo vehicles
      bt_testco = Location.find_or_create_by!(code: 'black-thunder-testco') do |l|
        l.description = 'Black Thunder (TestCo)'
        l.company_id = testco.id
        l.attainment = false
      end
      Rails.logger.info "Location: Black Thunder TestCo (ID #{bt_testco.id})"
    end

    # =========================================================================
    # 6. MAP VEHICLES TO CORRECT ENGINE CONFIGS
    # =========================================================================
    # Build a lookup from CSV: vehicle name → engine config code
    vehicle_config_map = {
      # Arch Coal Drills — Cat 3508 Single Stack
      'Drill 19' => '3508-DRILL', 'Drill 25' => '3508-DRILL', 'Drill 28' => '3508-DRILL',

      # Barrick Gold — mixed engines
      'HT634' => 'QSK60-HT', 'HT 639' => 'QSK60-HT',
      'HT617' => '16V4000-HT', 'HT624' => '16V4000-HT',
      'HT628' => '16V4000-T4-HT',

      # OCP Belaz/Hitachi — Cummins QSK50
      'Belaz #100' => 'QSK50-HT', 'Belaz #101' => 'QSK50-HT',
      'Belaz #102' => 'QSK50-HT', 'Belaz #103' => 'QSK50-HT',
      'Hitachi #001' => 'QSK50-HT', 'Hitachi #004' => 'QSK50-HT',

      # OCP Komatsu/Unit Rig — Cummins K2000
      'Komatsu #302' => 'K2000-HT', 'Komatsu #305' => 'K2000-HT',
      'Komatsu #310' => 'K2000-HT', 'Komatsu #322' => 'K2000-HT',
      'Komatsu #325' => 'K2000-HT', 'Komatsu #329' => 'K2000-HT',
      'Unit Rig #213' => 'K2000-HT', 'Unit Rig #217' => 'K2000-HT',

      # OEM Asia Pilot — Cummins QSK60
      '16' => 'QSK60-HT', '17' => 'QSK60-HT', '18' => 'QSK60-HT',
      '19' => 'QSK60-HT', '20' => 'QSK60-HT',

      # Redmond — Cat C27
      'HT4' => 'C27-HT',

      # Rio Tinto — Cummins QSK78
      'HT 401' => 'QSK78-HT', 'HT473' => 'QSK78-HT', 'HT476' => 'QSK78-HT',
      'HT1201' => 'QSK78-HT', 'HT1209' => 'QSK78-HT',

      # US SOCOM — John Deere 606
      'Generator 138' => '606-GEN',

      # UTA FrontRunner — EMD (most) + Cat C18 (UTA21-Alt)
      'UTA21-Alt' => 'C18-GEN',
    }

    # UTA Main engines are all EMD
    (1..21).each do |n|
      name = "UTA#{n.to_s.rjust(2,'0')}-Main"
      vehicle_config_map[name] = '16-645F3B-LOCO'
    end

    # TestCo Hazard vehicles — mixed
    ['HT001','HT002','HT007','HT008','HT009','HT010'].each { |v| vehicle_config_map[v] = 'QSK60-HT' }
    ['HT003','HT004','HT005','HT006'].each { |v| vehicle_config_map[v] = '16V4000-HT' }

    # TestCo Black Thunder — Cat C175 (HT011-HT017) and Cat 3516 (HT018-HT074)
    (11..17).each { |n| vehicle_config_map["HT0#{n}"] = 'C175-HT' }
    (18..74).each do |n|
      name = n < 100 ? "HT0#{n}" : "HT#{n}"
      vehicle_config_map[name] = '3516-HT'
    end

    # Apply the mappings
    updated = 0
    not_found = 0
    vehicle_config_map.each do |vehicle_name, config_code|
      ec = configs[config_code]
      unless ec
        Rails.logger.warn "Config #{config_code} not found for vehicle #{vehicle_name}"
        next
      end

      # Try to find vehicle by description (most common) or code
      vehicle = Vehicle.where("description = ? OR description LIKE ? OR code = ? OR code LIKE ?",
                              vehicle_name, "%#{vehicle_name}%", vehicle_name, "%#{vehicle_name}%").first

      if vehicle
        old_config = vehicle.engine_config_id
        vehicle.update_columns(engine_config_id: ec.id)
        if old_config != ec.id
          Rails.logger.info "Vehicle '#{vehicle.description}' (ID #{vehicle.id}): config #{old_config} → #{ec.id} (#{config_code})"
          updated += 1
        end
      else
        not_found += 1
      end
    end

    Rails.logger.info "Vehicle config mapping: #{updated} updated, #{not_found} not found in database"

    # =========================================================================
    # 7. FIX TYPOS
    # =========================================================================
    # Fix "Caterpillarerpillar" in any input records
    if Input.column_names.include?('engine_make')
      count = Input.where(engine_make: 'Caterpillarerpillar').update_all(engine_make: 'Caterpillar')
      Rails.logger.info "Fixed #{count} 'Caterpillarerpillar' typos in inputs" if count > 0
    end

    # =========================================================================
    # 8. RE-RUN DIAGNOSTIC STATUSES
    # =========================================================================
    Rails.logger.info "=== Data reconciliation complete ==="
    Rails.logger.info "Run 'rails update:diagnostic_statuses' to refresh all vehicle statuses"
  end

  def down
    # Data migration — not reversible
  end
end
