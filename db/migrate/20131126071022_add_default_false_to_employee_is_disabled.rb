class AddDefaultFalseToEmployeeIsDisabled < ActiveRecord::Migration
  def change
    change_column :employees, :is_disabled, :boolean, :default => false
  end
end
