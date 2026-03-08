class RemoveDuplicateInputs < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DELETE FROM inputs
      WHERE id NOT IN (
        SELECT MIN(id)
        FROM inputs
        WHERE auto_generated = true
        GROUP BY vehicle_id, submitted
      )
      AND auto_generated = true;
    SQL
  end

  def down
  end
end
