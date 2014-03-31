class ManyToManyEmployeeOrganizationsAssociation < ActiveRecord::Migration
  def change
    create_table :employees_organizations do |t|
      t.integer :employee_id
      t.integer :organization_id

      t.timestamps
    end

    if column_exists? :employees, :organization_id
      Authorization.ignore_access_control(true)

      Employee.all.each do |e|
        unless e.organization_id.blank?
          o = Organization.find_by_id(u.organization_id)
          e.organizations = o.nil? ? [] : [o]
          e.save
        end
      end

      remove_column :employees, :organization_id
    end
  end
end
