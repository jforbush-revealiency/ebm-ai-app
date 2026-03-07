class FixTelematicTestTypes < ActiveRecord::Migration[7.1]
  def up
    # Set all auto-generated inputs to manual first
    Input.where(auto_generated: true).update_all(test_type: 'manual')
    
    # Then re-set only the Redmond HT4 telematic records back to telematic
    # These are identified by their vehicle codes starting with 'Testht'
    Vehicle.where("LOWER(folder_code) LIKE 'testht%'").each do |v|
      Input.where(vehicle_code: v.folder_code).update_all(test_type: 'telematic')
    end
  end

  def down
    Input.where(auto_generated: true).update_all(test_type: nil)
  end
end
