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
      m = Manufacturer.find_by(code: code)
      unless m
        # Try case-insensitive
        m = Manufacturer.where("LOWER(code) = ?", code.downcase).first
      end
      unless m
        m = Manufacturer.create!(code: code, description: name)
      end
      manufacturers[code] = m
      Rails.logger.info "Manufacturer: #{name} (ID #{m.id})"
    end

    # =========================================================================
    # 2. ENGINES — ensure all exist with correct single_stack flag
    # =========================================================================
    engines = {}
    [
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
      e = Engine.find_by(code: code)
      unless e
        e = Engine.where("LOWER(code) = ?", code.downcase).first
      end
      if e
        e.update_columns(description: desc, manufacturer_id: manufacturers[mfr_code].id, is_single_stack: single)
      else
        e = Engine.create!(code: code, description: desc, manufacturer_id: manufacturers[mfr_code].id, is_single_stack: single)
      end
      engines[code] = e
      Rails.logger.info "Engine: #{desc} (ID #{e.id}, single_stack=#{single})"
    end

    # =========================================================================
    # 3. ENGINE CONFIGS — one per engine variant with correct baselines
    # =========================================================================
    configs = {}
    [
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
      ec = EngineConfig.find_by(code: code)
      if ec
        ec.update_columns(description: desc, engine_id: engine.id, co2_percent: co2, co: co, nox: nox, rated_rpm: rpm, rated_hp: hp)
      else
        ec = EngineConfig.create!(code: code, description: desc, engine_id: engine.id, co2_percent: co2, co: co, nox: nox, rated_rpm: rpm, rated_hp: hp)
      end
      configs[code] = ec
      Rails.logger.info "EngineConfig: #{desc} (ID #{ec.id}) — CO2:#{co2}% CO:#{co} NOx:#{nox} RPM:#{rpm} HP:#{hp}"
    end

    # =========================================================================
    # 4. MERGE DUPLICATE ENGINE CONFIGS
    # =========================================================================
    merge_configs_by_pattern('%QSK60%', configs['QSK60-HT'])
    merge_configs_by_pattern('%16V%4000%', configs['16V4000-HT'], exclude_pattern: '%T4%')
    merge_configs_by_pattern('%606%', configs['606-GEN'])

    # =========================================================================
    # 5. LOCATIONS — create Hazard for TestCo
    # =========================================================================
    testco = Company.where("LOWER(code) LIKE '%testco%'").first
    if testco
      hazard = Location.find_by(code: 'hazard')
      unless hazard
        hazard = Location.create!(code: 'hazard', description: 'Hazard', company_id: testco.id, attainment: false)
      end
      Rails.logger.info "Location: Hazard (ID #{hazard.id}) under TestCo (ID #{testco.id})"

      bt_testco = Location.find_by(code: 'black-thunder-testco')
      unless bt_testco
        bt_testco = Location.create!(code: 'black-thunder-testco', description: 'Black Thunder (TestCo)', company_id: testco.id, attainment: false)
      end
      Rails.logger.info "Location: Black Thunder TestCo (ID #{bt_testco.id})"
    end

    # =========================================================================
    # 6. MAP VEHICLES TO CORRECT ENGINE CONFIGS
    # =========================================================================
    vehicle_config_map = {
      'Drill 19' => 'QSK60-HT', 'Drill 25' => '3508-DRILL', 'Drill 28' => '3508-DRILL',
      'HT634' => 'QSK60-HT', 'HT 639' => 'QSK60-HT',
      'HT617' => '16V4000-HT', 'HT624' => '16V4000-HT', 'HT628' => '16V4000-T4-HT',
      'Belaz #100' => 'QSK50-HT', 'Belaz #101' => 'QSK50-HT',
      'Belaz #102' => 'QSK50-HT', 'Belaz #103' => 'QSK50-HT',
      'Hitachi #001' => 'QSK50-HT', 'Hitachi #004' => 'QSK50-HT',
      'Komatsu #302' => 'K2000-HT', 'Komatsu #305' => 'K2000-HT',
      'Komatsu #310' => 'K2000-HT', 'Komatsu #322' => 'K2000-HT',
      'Komatsu #325' => 'K2000-HT', 'Komatsu #329' => 'K2000-HT',
      'Unit Rig #213' => 'K2000-HT', 'Unit Rig #217' => 'K2000-HT',
      '16' => 'QSK60-HT', '17' => 'QSK60-HT', '18' => 'QSK60-HT',
      '19' => 'QSK60-HT', '20' => 'QSK60-HT',
      'HT4' => 'C27-HT',
      'HT 401' => 'QSK78-HT', 'HT473' => 'QSK78-HT', 'HT476' => 'QSK78-HT',
      'HT1201' => 'QSK78-HT', 'HT1209' => 'QSK78-HT',
      'Generator 138' => '606-GEN',
      'UTA21-Alt' => 'C18-GEN',
    }
    (1..21).each { |n| vehicle_config_map["UTA#{n.to_s.rjust(2,'0')}-Main"] = '16-645F3B-LOCO' }
    ['HT001','HT002','HT007','HT008','HT009','HT010'].each { |v| vehicle_config_map[v] = 'QSK60-HT' }
    ['HT003','HT004','HT005','HT006'].each { |v| vehicle_config_map[v] = '16V4000-HT' }
    (11..17).each { |n| vehicle_config_map["HT0#{n}"] = 'C175-HT' }
    (18..74).each { |n| vehicle_config_map[n < 100 ? "HT0#{n}" : "HT#{n}"] = '3516-HT' }

    updated = 0
    vehicle_config_map.each do |vehicle_name, config_code|
      ec = configs[config_code]
      next unless ec
      vehicle = Vehicle.where("description = ? OR code = ?", vehicle_name, vehicle_name).first
      vehicle ||= Vehicle.where("description LIKE ?", "%#{vehicle_name}%").first
      if vehicle && vehicle.engine_config_id != ec.id
        vehicle.update_columns(engine_config_id: ec.id)
        Rails.logger.info "Vehicle '#{vehicle.description}' (ID #{vehicle.id}): → config #{ec.id} (#{config_code})"
        updated += 1
      end
    end
    Rails.logger.info "Vehicle config mapping: #{updated} updated"

    # =========================================================================
    # 7. FIX TYPOS
    # =========================================================================
    if Input.column_names.include?('engine_make')
      count = Input.where(engine_make: 'Caterpillarerpillar').update_all(engine_make: 'Caterpillar')
      Rails.logger.info "Fixed #{count} 'Caterpillarerpillar' typos" if count > 0
    end

    Rails.logger.info "=== Data reconciliation complete ==="
  end

  def down
  end

  private

  def merge_configs_by_pattern(pattern, canonical, exclude_pattern: nil)
    scope = EngineConfig.where("code LIKE ?", pattern).where.not(id: canonical.id)
    scope = scope.where.not("code LIKE ?", exclude_pattern) if exclude_pattern
    scope.each do |old|
      count = Vehicle.where(engine_config_id: old.id).count
      Vehicle.where(engine_config_id: old.id).update_all(engine_config_id: canonical.id)
      Rails.logger.info "Merged config '#{old.code}' (ID #{old.id}) → '#{canonical.code}' (ID #{canonical.id}). Moved #{count} vehicles."
      old.destroy! if Vehicle.where(engine_config_id: old.id).count == 0
    end
  end
end
