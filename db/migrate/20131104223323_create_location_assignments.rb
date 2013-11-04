class CreateLocationAssignments < ActiveRecord::Migration
  def change
    create_table :location_assignments do |t|
      t.integer :location_id
      t.integer :employee_id

      t.timestamps
    end
  end
end
