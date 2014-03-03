class AddDefaultsToEmployeeSchedules < ActiveRecord::Migration
  def change
    change_column :employee_schedules, :availability_submitted, :boolean, :default => false
  end
end
