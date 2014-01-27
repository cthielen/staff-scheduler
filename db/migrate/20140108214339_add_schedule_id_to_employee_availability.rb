class AddScheduleIdToEmployeeAvailability < ActiveRecord::Migration
  def change
    add_column :employee_availabilities, :schedule_id, :integer
  end
end
