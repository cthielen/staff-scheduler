class AddRmidToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :rm_id, :int
  end
end
