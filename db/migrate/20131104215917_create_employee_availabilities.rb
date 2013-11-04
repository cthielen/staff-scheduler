class CreateEmployeeAvailabilities < ActiveRecord::Migration
  def change
    create_table :employee_availabilities do |t|
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.integer :employee_id

      t.timestamps
    end
  end
end
