class CreateShiftAssignmentStatuses < ActiveRecord::Migration
  def change
    create_table :shift_assignment_statuses do |t|
      t.string :name

      t.timestamps
    end
  end
end
