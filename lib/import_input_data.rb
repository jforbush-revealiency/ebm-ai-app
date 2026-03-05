module ImportInputData
  class Import
    def path
      @path
    end
    def path=(path)
      @path=path
    end

    def import_as_user
      @import_as_user
    end

    def import_as_user=(user)
      @import_as_user=user
    end

    def purge
      Input.where(user_id: import_as_user.id).delete_all
    end

    def start
      puts "Importing Input Data"
      counter = 0
      Time.use_zone("Mountain Time (US & Canada)") do
        CSV.foreach(path, {headers: :first_row}) do |row|
          counter+=1;
          vehicle_code = row[0]
          vehicle_model = row[1]
          vehicle_serial = row[2]
          engine_hours = row[3]
          engine_model = row[4]
          engine_rpm = row[5]
          alternator_rpm = row[6]
          engine_hp = row[7]
          alternator_hp = row[8]
          left_co2_percentage = row[9]
          left_co = row[10]
          left_nox = row[11]
          right_co2_percentage = row[12]
          right_co = row[13]
          right_nox = row[14]
          location_code = row[15]
          company_code = row[16]
          submitted = row[17]
          drive_type = row[18]
          engine_manufacturer = row[19]
          config_co2_percent = row[20]
          config_co = row[21]
          config_nox = row[22]

          unless engine_hours.present?
            engine_hours = 0
          end

          if vehicle_code.present? 
            company = Company.find_by_code(company_code)
            if company.nil?
              company = Company.create(code: company_code)
            end

            location = company.locations.find_by_code(location_code)
            if location.nil?
              location = company.locations.create(code: location_code)
            end

            vehicle = location.vehicles.find_by_code(vehicle_code)
            if vehicle.nil?

              manufacturer = Manufacturer.find_by_code(engine_manufacturer)
              if manufacturer.nil?
                puts "Unable to find the manufacturer #{engine_manufacturer} on line #{counter}"
                next
              end
              
              engine = manufacturer.engines.find_by_code(engine_model)
              if engine.nil?
                puts "Unable to find the engine #{engine_model} on line #{counter}"
                next
              end

              engine_config = engine.engine_configs.find_by_code(engine_model)
              if engine_config.nil?
                puts "Unable to find the engine config #{engine_model} on line #{counter}"
                next
              end

              vehicle = location.vehicles.create(engine_config: engine_config, 
                                                code: vehicle_code, model_number: vehicle_model,
                                                serial_number: vehicle_serial)
            end
            
            input = Input.new
            submitted_parsed = DateTime.strptime(submitted, "%m/%d/%y")
            input.submitted = Time.zone.parse(submitted_parsed.strftime("%Y-%m-%d %T"))
            input.vehicle_id = vehicle.id
            input.has_engine_codes = 0 
            input.has_latest_configuration_file = 'N/A' 
            input.engine_hours = engine_hours 
            input.engine_rpm = engine_rpm 
            input.alternator_rpm = alternator_rpm 
            input.engine_hp = engine_hp 
            input.alternator_hp = alternator_hp 
            input.left_bank_co2_percent = left_co2_percentage.to_d
            input.left_bank_co = left_co
            input.left_bank_nox = left_nox
            input.right_bank_co2_percent = right_co2_percentage.to_d
            input.right_bank_co = right_co
            input.right_bank_nox = right_nox

            if !input.commit(import_as_user, location, input.submitted)
              puts "Unable to save input record number #{counter}"
              puts input.errors.inspect
              next
            end

            ProcessInputsJob.set(wait: 10.minutes).perform_later input
          end
        end
        puts "Imported #{counter} input records"
      end
    end
    def fix_dates(inputs)
      puts "Fixing Dates"
      counter = 0
      Time.use_zone("Mountain Time (US & Canada)") do
        puts Time.zone.now
        CSV.foreach(path, {headers: :first_row}) do |row|
          vehicle_code = row[0]
          vehicle_model = row[1]
          vehicle_serial = row[2]
          engine_hours = row[3]
          engine_model = row[4]
          engine_rpm = row[5]
          alternator_rpm = row[6]
          engine_hp = row[7]
          alternator_hp = row[8]
          left_co2_percentage = row[9]
          left_co = row[10]
          left_nox = row[11]
          right_co2_percentage = row[12]
          right_co = row[13]
          right_nox = row[14]
          location_code = row[15]
          company_code = row[16]
          submitted = row[17]
          drive_type = row[18]
          engine_manufacturer = row[19]
          config_co2_percent = row[20]
          config_co = row[21]
          config_nox = row[22]
            
          input = inputs[counter]
          submitted_parsed = DateTime.strptime(submitted, "%m/%d/%y")
          input.submitted = Time.zone.parse(submitted_parsed.strftime("%Y-%m-%d %T"))
          input.save!

          counter+=1;
        end
      end
      puts "Fixed #{counter} input records"
    end
  end

  def ImportInputData.purge
    user = User.find_by_role("imports")
    if user.nil?
      puts "Unable to find a user with a role of imports"
      return
    end

    import = Import.new
    import.import_as_user = user 
    import.purge

    puts "Finished purging"
  end
  def ImportInputData.run(path)
    puts path
    user = User.find_by_role("imports")
    if user.nil?
      puts "Unable to find a user with a role of imports"
      return
    end

    import = Import.new
    import.path = path 
    import.import_as_user = user 
    import.start
  end
  def ImportInputData.fix_dates(path)
    puts path
    company_code = "TestCo"
    company = Company.find_by_code(company_code)
    if company.nil?
      puts "Unable to find the company code of #{company_code}"
      return
    end

    location_code = "TestLocation"
    location = company.locations.find_by_code(location_code)
    if location.nil?
      puts "Unable to find the location code of #{location_code}"
      return
    end

    import = Import.new
    import.path = path 
    import.fix_dates(location.inputs.order(:id))
  end
end

