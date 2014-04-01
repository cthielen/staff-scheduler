class DropEmplyeesOrganizationsTable < ActiveRecord::Migration
  def change
    drop_table :employees_organizations if self.table_exists?("employees_organizations")
  end
end
