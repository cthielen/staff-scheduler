class Schedule < ActiveRecord::Base
  using_access_control
  
  has_many :shifts
  
  validates :start_date, :end_date, presence: true

  # State Machine

  # Initial state after schedule creation
  PENDING_AVAILABILITIES = 1
  # Entering State Action: Email employees a link to the availability creation form
  # Leave State Condition: Change to state 2 when all active employee availabilities have been accounted for.  
  
  # Ready to have shift_assignments associated to schedule
  PENDING_ASSIGNMENTS = 2
  # Entering State Action: Email managers that all availabilities have been received and schedule_assignments can be filled in
  # Leave State Condition: Change to state 3 when the 'complete' button on the Schedule Planner form is clicked.  

  # Shift_assignments in schedule need to be confirmed
  PENDING_CONFIRMATION = 3
  # Entering State Action: Email employees with uncomfirmed shift_assignments a link to the shift_assignment confirmation form
  # Leave State Condition: Change to state 4 when all shift_assignments associated to schedule have been confirmed.  

  # All shift_assignments are confirmed
  COMPLETE = 4
  # Entering State Action: Email managers a notification that the schedule is complete
  # Action Triggers: An Availability changed - email managers a notification
  # Action Triggers: Shift_assignment Absence generated - email all employees a link to the schedule
  # Action Triggers: Unfilled Shift_exception in schedule tomorrow - email managers a notification
  # Leave State Condition: Change to state 3 when Availability and shift_assignment conflict is detected - email managers a notification
  # Leave State Condition: Change to state 3 when new shift_assignment detected 
  # Leave State Condition: Change to state 5 when schedule end_date is passed
  
  # Schedule no longer in use
  INACTIVE = 5
end
