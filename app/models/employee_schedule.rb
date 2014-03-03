class EmployeeSchedule < ActiveRecord::Base
  using_access_control

  # This model tracks which employees have been assigned to which schedules, and the state of their availability submission

  belongs_to :employee
  belongs_to :schedule

  validates :employee_id, :schedule_id, presence: true
  validates :availability_submitted, :inclusion => {:in => [true, false]}

end
