class RenameMaxHoursOnEmployees < ActiveRecord::Migration
  def change
    rename_column :employees, :max_hours, :global_max_hours
  end
end
