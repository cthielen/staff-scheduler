class AddStateColumnToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, :state, :integer, default: 1
  end
end
