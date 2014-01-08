class EmployeeAvailability < ActiveRecord::Base
  using_access_control
  
  belongs_to :employee
  belongs_to :schedule

  validates :start_datetime, :end_datetime, :schedule_id, presence: true
end
