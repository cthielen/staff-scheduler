class AddOrganizationIdToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, :organization_id, :integer
  end
end
