class User < ActiveRecord::Base
  using_access_control

  belongs_to :employee
  has_and_belongs_to_many :organizations

  validates_presence_of :loginid
  validates :is_manager, :inclusion => { :in => [true, false] }

  def role_symbols
    RolesManagement.fetch_role_symbols_by_loginid(loginid)
  end
end
