class CreateShiftAssignments < ActiveRecord::Migration
  def change
    create_table :shift_assignments do |t|
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.integer :employee_id
      t.boolean :is_absence
      t.boolean :is_confirmed
      t.integer :shift_id

      t.timestamps
    end
  end
end
