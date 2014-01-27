class AddDefaultValueToStatusOnShiftAssignment < ActiveRecord::Migration
  def change
  change_column :shift_assignments, :status_id, :integer,:default => 1
  end
end
