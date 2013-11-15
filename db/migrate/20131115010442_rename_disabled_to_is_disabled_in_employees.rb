class RenameDisabledToIsDisabledInEmployees < ActiveRecord::Migration
  def change
    rename_column :employees, :disabled, :is_disabled
    change_column :employees, :is_disabled, :boolean, :default => true 
  end
end
