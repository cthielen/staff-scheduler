class ShiftAssignment < ActiveRecord::Base
  using_access_control
  
  belongs_to :employee
  belongs_to :shift
  
  validates :start_datetime, :end_datetime, :employee_id, :is_confirmed, :shift_id, presence: true
end
