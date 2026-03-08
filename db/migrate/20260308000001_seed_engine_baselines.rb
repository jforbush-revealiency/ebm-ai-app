class SeedEngineBaselines < ActiveRecord::Migration[7.1]
  def up
    baselines = {
      'CAT-C27'                        => { co2: 7.3,  co: 115.0, nox: 582.0  },
      'C27'                            => { co2: 7.3,  co: 115.0, nox: 582.0  },
      'QSK60'                          => { co2: 9.2,  co: 300.0, nox: 1020.0 },
      'QSK60-Tier1-2500 HP, 1900 RPM'  => { co2: 9.2,  co: 300.0, nox: 1020.0 },
      'QSK50'                          => { co2: 9.0,  co: 280.0, nox: 980.0  },
      'K2000'                          => { co2: 9.5,  co: 300.0, nox: 1050.0 },
      '3508'                           => { co2: 9.0,  co: 250.0, nox: 950.0  },
      '3516'                           => { co2: 9.0,  co: 250.0, nox: 950.0  },
      'C175'                           => { co2: 9.0,  co: 250.0, nox: 950.0  },
      'C18'                            => { co2: 8.5,  co: 200.0, nox: 850.0  },
      '16V-4000'                       => { co2: 8.5,  co: 200.0, nox: 800.0  },
      'MTU 16V-4000 - Tier4'           => { co2: 8.5,  co: 200.0, nox: 800.0  },
      '16-645F3B'                      => { co2: 6.28, co: 164.0, nox: 710.0  },
      'QSK78'                          => { co2: 9.2,  co: 320.0, nox: 1050.0 },
      '606'                            => { co2: 8.0,  co: 180.0, nox: 800.0  },
    }

    baselines.each do |engine_code, vals|
      engine = Engine.find_by(code: engine_code)
      next unless engine

      EngineConfig.where(engine_id: engine.id).each do |ec|
        ec.co2_percent = vals[:co2] if ec.co2_percent.nil? || ec.co2_percent == 12.5
        ec.co          = vals[:co]  if ec.co.nil?
        ec.nox         = vals[:nox] if ec.nox.nil?
        ec.save! if ec.changed?
      end
    end
  end

  def down
    # intentionally blank — don't reverse baseline data
  end
end
