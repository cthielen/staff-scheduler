class AddStatusToShiftAssignments < ActiveRecord::Migration
  def change
    add_column :shift_assignments, :status_id, :integer
  end
end
