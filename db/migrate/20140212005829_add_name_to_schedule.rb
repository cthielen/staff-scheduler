class AddNameToSchedule < ActiveRecord::Migration
  def change
    add_column :schedules, :name, :string
  end
end
