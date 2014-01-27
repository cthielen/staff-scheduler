class ShiftAssignmentStatus < ActiveRecord::Base
  using_access_control
  
  has_many :shift_assignments
  
  validates :name, presence: true
  # Suggest Statuses:
  
  # Scheduled
  # Sick
  # Absent
  # Vacation
  # Worked
  
end
