class AddingDefaultsToShiftAssignments < ActiveRecord::Migration
  def change
    change_column :shift_assignments, :is_confirmed, :boolean, :default => false
  end
end
