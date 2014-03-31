class ManyToManyOrganizationsUsersAssociation < ActiveRecord::Migration
  def change
    create_table :organizations_users do |t|
      t.integer :user_id
      t.integer :organization_id

      t.timestamps
    end

    if column_exists? :users, :organization_id
      Authorization.ignore_access_control(true)

      User.all.each do |u|
        unless u.organization_id.blank?
          o = Organization.find_by_id(u.organization_id)
          u.organizations = o.nil? ? [] : [o]
          u.save
        end
      end

      remove_column :users, :organization_id
    end
  end
end
