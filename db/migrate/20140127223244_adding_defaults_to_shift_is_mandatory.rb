class AddingDefaultsToShiftIsMandatory < ActiveRecord::Migration
  def change
    change_column :shifts, :is_mandatory, :boolean, :default => false
  end
end
