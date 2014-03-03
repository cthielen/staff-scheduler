class CreateEmployeeSchedules < ActiveRecord::Migration
  def change
    create_table :employee_schedules do |t|
      t.integer :schedule_id
      t.integer :employee_id

      t.timestamps
    end
  end
end
