class AddDefaultFalseToUserIsManager < ActiveRecord::Migration
  def change
    change_column :users, :is_manager, :boolean, :default => false
  end
end
