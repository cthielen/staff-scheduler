class ShiftAssignmentStatus < ActiveRecord::Base
  using_access_control
  
  has_many :shift_assignments
  
  validates :name, presence: true
  # Available Statuses:
  # Planned -- assigned, has not yet occured
  # Completed -- assigned, confirmed, and date has passed
  # Rejected -- for when a shift_assignment is given to a person by a manager, but they do not confirm it and cancel the assignment reject it.
  # Rejected is also used for the situation where an assignment is not confirmed, and the date passes. Auto-rejects.
  # Sick -- un-assigned a confirmed assignment, for sickness
  # Absent -- un-assigned a confirmed assignment, ahead of time
  # Vacation -- un-assigneda confirmed assignment, for vacation
  # No_Show -- un-assigned a confirmed assignment, employee didn't show up for their shift
end
