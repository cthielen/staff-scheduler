class EmployeeAvailability < ActiveRecord::Base
  using_access_control
  
  belongs_to :employee

  validates :start_datetime, :end_datetime, presence: true
end
