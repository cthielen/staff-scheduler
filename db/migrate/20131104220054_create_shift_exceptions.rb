class CreateShiftExceptions < ActiveRecord::Migration
  def change
    create_table :shift_exceptions do |t|
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.integer :employee_id
      t.boolean :is_absence
      t.integer :shift_id

      t.timestamps
    end
  end
end
