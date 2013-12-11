class Schedule < ActiveRecord::Base
  using_access_control
  
  has_many :shifts
  
  validates :start_date, :end_date, presence: true

  # State Machine
  # Notes: Transition Actions go on 'exits' not 'beginnings'
  
  # Schedule in progress (shifts being created)
  INCOMPLETE_SCHEDULE = 0
  # Action: If schedule is empty, copy old schedule shifts
  # Action: refuse to create if overlaps with other schedule 
  # Exit Condition: 'Complete' button clicked in schedule planning form
  # Exit Command: Email employees a link to the availability creation form
  
  # Initial state after schedule creation
  PENDING_AVAILABILITIES = 1
  # Exit Condition: Change to state 2 when all active employee availabilities have been accounted for.  
  # Exit Command: Email managers that all availabilities have been received and shift_assignments can be filled in
  
  # Ready to have shift_assignments associated to schedule
  PENDING_ASSIGNMENTS = 2
  # Exit Condition: Change to state 3 when the 'complete' button on the Schedule Planner form is clicked.  
  # Exit Command: Email employees with uncomfirmed shift_assignments a link to the shift_assignment confirmation form
  
  # Shift_assignments in schedule need to be confirmed
  PENDING_CONFIRMATION = 3
  # Exit Condition: Change to state 4 when all shift_assignments associated to schedule have been confirmed.  
  # Exit Command: Email managers a notification that the schedule is ready

  # All shift_assignments are confirmed
  READY = 4
  # Exit condition: Change to state 5 when schedule start date is reached

  # Schedule start date has been reached
  ACTIVE = 5
  # Action: An Availability changed - email managers a notification
  # Action: Shift_assignment Absence generated - email all employees a link to the schedule
  # Action: Unfilled Shift_exception in schedule tomorrow - email managers a notification
  # Action: Shift_exception absence created - email employee (In both cases, when created by manager or employee)
  # Exit Condition: Change to state 3 when Availability and shift_assignment conflict is detected - email managers a notification
  # Exit Condition: Change to state 3 when new shift_assignment detected 
  # Exit Condition: Change to state 6 when schedule end_date is passed
  
  # Schedule no longer in use
  INACTIVE = 6
  
  # Runs state machine 'loop' of currently active schedule
  def process_state
    case current_state
    
    when INCOMPLETE_SCHEDULE
    
    when PENDING_AVAILABILITIES
    
    when PENDING_ASSIGNMENTS
    
    when PENDING_CONFIRMATION
    
    when READY
    
    when ACTIVE
    
    when INACTIVE
      
    else
      "Schedule has been put into an invalid state"
    end
  end
    
  # Triggers: Human actions that directly trigger state changes
  def trigger_schedule_created
  end
  
  def trigger_shift_assignments_created
  def
      
  # Action requests: Email links to forms to trigger human action
        
  def request_availability_form
  end
  
  def request_confirmation_form
  end
  
  def request_shift_exception_fill
  end

  # Action notifications: Emails status update
  
  def notify_schedule_complete
  end
  
  def notify_availability_change
  end
  
  def notify_absence
  end
  
  def notify_unfilled_absence
  end
  
  def notify_schedule_conflict
  end

  def notify_all_availabilities_received
  end
  
  # Exit state checks

  def check_availabilities
  end
  
  def check_shift_assignment_confirmations
  end
  
