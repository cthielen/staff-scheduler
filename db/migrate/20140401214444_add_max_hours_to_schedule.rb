class AddMaxHoursToSchedule < ActiveRecord::Migration
  def change
    add_column :schedules, :max_hours, :integer
  end
end
