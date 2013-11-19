class ShiftException < ActiveRecord::Base
  using_access_control
  
  belongs_to :employee
  belongs_to :shift
  
  validates :start_datetime, :end_datetime, :is_absence, :employee_id, :shift_id, presence: true
end
