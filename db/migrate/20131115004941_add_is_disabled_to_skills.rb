class AddIsDisabledToSkills < ActiveRecord::Migration
  def change
    add_column :skills, :is_disabled, :boolean, :default => false
  end
end
