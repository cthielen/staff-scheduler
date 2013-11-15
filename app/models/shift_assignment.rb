class ShiftAssignment < ActiveRecord::Base
  belongs_to :employee
  belongs_to :shift
  
  validates :start_datetime, :end_datetime, :employee_id, :is_confirmed, :shift_id, presence: true
end
