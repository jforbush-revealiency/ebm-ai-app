class AddUpdatedFieldsToInput < ActiveRecord::Migration[5.0]
  def up
    add_column :inputs, :updated_by_first_name, :string
    add_column :inputs, :updated_by_last_name, :string
    add_column :inputs, :updated_by_email, :string
  end

  def down
    remove_column :inputs, :updated_by_first_name, :string
    remove_column :inputs, :updated_by_last_name, :string
    remove_column :inputs, :updated_by_email, :string
  end
end
