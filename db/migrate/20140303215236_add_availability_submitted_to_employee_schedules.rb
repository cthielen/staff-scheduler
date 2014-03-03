class AddAvailabilitySubmittedToEmployeeSchedules < ActiveRecord::Migration
  def change
    add_column :employee_schedules, :availability_submitted, :boolean
  end
end
