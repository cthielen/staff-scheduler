class ShiftAssignment < ActiveRecord::Base
  using_access_control
  
  belongs_to :employee
  belongs_to :shift
  belongs_to :shift_assignment_status
  
  validates :start_datetime, :end_datetime, :employee_id, :is_confirmed, :status_id, :shift_id, presence: true
end
