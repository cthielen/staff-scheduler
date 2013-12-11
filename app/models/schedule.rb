class Schedule < ActiveRecord::Base
  using_access_control
  
  has_many :shifts
  
  validates :start_date, :end_date, presence: true

  # State Machine

  # Initial state after schedule creation
  PENDING_AVAILABILITIES = 1
  # Begin Command: Email employees a link to the availability creation form
  # Exit Condition: Change to state 2 when all active employee availabilities have been accounted for.  
  
  # Ready to have shift_assignments associated to schedule
  PENDING_ASSIGNMENTS = 2
  # Begin Command: Email managers that all availabilities have been received and schedule_assignments can be filled in
  # Exit Condition: Change to state 3 when the 'complete' button on the Schedule Planner form is clicked.  

  # Shift_assignments in schedule need to be confirmed
  PENDING_CONFIRMATION = 3
  # Begin Command: Email employees with uncomfirmed shift_assignments a link to the shift_assignment confirmation form
  # Exit Condition: Change to state 4 when all shift_assignments associated to schedule have been confirmed.  

  # All shift_assignments are confirmed
  ACTIVE = 4
  # Begin Command: Email managers a notification that the schedule is complete
  # Action Trigger: An Availability changed - email managers a notification
  # Action Trigger: Shift_assignment Absence generated - email all employees a link to the schedule
  # Action Trigger: Unfilled Shift_exception in schedule tomorrow - email managers a notification
  # Action Trigger: Shift_exception absence created - email employee (In both cases, when created by manager or employee)
  # Exit Condition: Change to state 3 when Availability and shift_assignment conflict is detected - email managers a notification
  # Exit Condition: Change to state 3 when new shift_assignment detected 
  # Exit Condition: Change to state 5 when schedule end_date is passed
  
  # Schedule no longer in use
  INACTIVE = 5

  def process_state(current_state)
    case current_state
    when PENDING_AVAILABILITIES
    
    when PENDING_ASSIGNMENTS
    
    when PENDING_CONFIRMATION
    
    when ACTIVE
    
    when INACTIVE
      
    else
      "Schedule has been given an invalid state"
    end
  end
  
  def request_availability_form
  end
  
  def notify_all_availabilities_received
  end
  
  def request_confirmation_form
  end
  
  def notify_schedule_complete
  end
  
  def notify_availability_change
  end
  
  def request_shift_exception_fill
  end
  
  def notify_absence
  end
  
  def notify_unfilled_absence
  end
  
  def notify_schedule_conflict
  end
end
