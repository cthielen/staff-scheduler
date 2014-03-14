class User < ActiveRecord::Base
  using_access_control
  
  belongs_to :employee
  belongs_to :organization
  
  validates_presence_of :loginid, :organization_id
  validates :is_manager, :inclusion => { :in => [true, false] }
  
  def role_symbols
    RolesManagement.fetch_role_symbols_by_loginid(loginid)
  end
end
