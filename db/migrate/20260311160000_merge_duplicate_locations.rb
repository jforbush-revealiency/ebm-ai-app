class MergeDuplicateLocations < ActiveRecord::Migration[7.1]
  def up
    # Merge OCP Morocco locations
    # Keep ID 15 (Morocco), absorb ID 4 (OCP-Morocco Pilot)
    merge_locations(keep_id: 15, remove_id: 4, final_name: "Morocco")

    # Merge TTJV Mongolia locations
    # Keep ID 16 (TTJV-Mongolia), absorb ID 5 (TTJV-Mongolia Pilot)
    merge_locations(keep_id: 16, remove_id: 5, final_name: "TTJV-Mongolia")

    # Merge Redmond locations
    # Keep ID 6 (Redmond Minerals), absorb ID 11 (REDMOND-SITE-1)
    merge_locations(keep_id: 6, remove_id: 11, final_name: "Redmond Minerals")

    Rails.logger.info "Location merge complete"
  end

  def down
    # Data migration — not reversible
  end

  private

  def merge_locations(keep_id:, remove_id:, final_name:)
    keep = Location.find_by(id: keep_id)
    remove = Location.find_by(id: remove_id)

    unless keep && remove
      Rails.logger.info "Skipping merge: keep=#{keep_id} (#{keep ? 'found' : 'missing'}), remove=#{remove_id} (#{remove ? 'found' : 'missing'})"
      return
    end

    # Move all vehicles from the duplicate to the keeper
    vehicle_count = Vehicle.where(location_id: remove.id).count
    Vehicle.where(location_id: remove.id).update_all(location_id: keep.id)

    # Move any inputs that reference the old location
    if Input.column_names.include?('location_id')
      Input.where(location_id: remove.id).update_all(location_id: keep.id)
    end

    # Move any users assigned to the old location
    if User.column_names.include?('location_id')
      User.where(location_id: remove.id).update_all(location_id: keep.id)
    end

    # Update the keeper's description
    keep.update_columns(description: final_name)

    # Delete the now-empty duplicate
    remove.destroy!

    Rails.logger.info "Merged location (ID #{remove_id}) into '#{keep.code}' (ID #{keep_id}). Moved #{vehicle_count} vehicles. Final name: #{final_name}"
  end
end
