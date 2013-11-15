class AddIsDisabledToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :is_disabled, :boolean, :default => false
  end
end
