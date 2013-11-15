class RemoveIsAbsenceFromShiftAssignments < ActiveRecord::Migration
  def change
      remove_column :shift_assignments, :is_absence, :boolean
  end
end
