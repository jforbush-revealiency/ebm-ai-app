class AddSingleStackToEngine < ActiveRecord::Migration[5.0]
  def up
    add_column :engines, :is_single_stack, :boolean, default: 0, null: false
  end
  def down
    remove_column :engines, :is_single_stack
  end
end
