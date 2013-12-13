class Schedule < ActiveRecord::Base
  using_access_control
  
  has_many :shifts
  
  validates :start_date, :end_date, presence: true

  # State Machine
  # ASSUMPTION: Transition Actions go on 'exits' not 'beginnings'
  # ASSUMPTION: schedules cannot overlap
  
  # Schedule in progress (shifts being created)
  INCOMPLETE_SCHEDULE = 1
  # Action: If schedule is empty, copy old schedule shifts
  # Action: refuse to create if overlaps with other schedule 
  # Exit Condition: Change to state 2 when 'complete' button clicked in schedule planning form
  # Exit Command: Email employees a link to the availability creation form
  
  # Initial state after schedule creation
  PENDING_AVAILABILITIES = 2
  # Exit Condition: Change to state 3 when all active employee availabilities have been accounted for.  
  # Exit Command: Email managers that all availabilities have been received and shift_assignments can be filled in
  
  # Ready to have shift_assignments associated to schedule
  PENDING_ASSIGNMENTS = 3
  # Exit Condition: Change to state 4 when the 'complete' button on the Schedule Planner form is clicked.  
  # Exit Command: Email employees with uncomfirmed shift_assignments a link to the shift_assignment confirmation form
  
  # Shift_assignments in schedule need to be confirmed
  PENDING_CONFIRMATION = 4
  # Exit Condition: Change to state 5 when all shift_assignments associated to schedule have been confirmed.  
  # Exit Command: Email managers a notification that the schedule is ready

  # All shift_assignments are confirmed
  READY = 5
  # Exit condition: Change to state 6 when schedule start date is reached

  # Schedule start date has been reached
  ACTIVE = 6
  # Action: Shift_assignment Absence generated - email all employees a link to the schedule, (email affected employee in case it was made by manager and for record keeping)
  # Action: Unfilled Shift_exception in schedule tomorrow - email managers a notification
  # Action: Employee changes availability - create necessary 'absences' for assigned shifts that no longer match
  # Action: Manager assigns shift_assignment to employee - email person for approval
  # Action: Manager creates shift without assigning an employee - email all employees to pick up shifts
  # Action: Manager creates shift and assigns an employee - email employee for confirmation
  # Exit Condition: Change to state 7 when schedule end_date is passed

  # Schedule no longer in use
  INACTIVE = 7
  
  # Runs state machine 'loop' of currently active schedule
  def process_state
    case current_state
    
    when INCOMPLETE_SCHEDULE
      
    when PENDING_AVAILABILITIES
      if check_availabilities == 0
        notify_availability_confirmations_complete
        this.state = 3
      end
    when PENDING_ASSIGNMENTS
    
    when PENDING_CONFIRMATION
      if check_shift_assignment_confirmations == 0
        notify_schedule_ready
        this.state = 5
      end
    when READY
      if Time.now > this.start_date
        this.state = 6
      end
    when ACTIVE
    
    when INACTIVE
      
    else
      "Schedule has been put into an invalid state"
    end
  end
    
  # Triggers: Human actions that directly trigger state changes
  def trigger_schedule_created
    this.state = 2
    this.save
  end
  
  def trigger_shift_assignments_created
    this.state = 4
    this.save
  end
      
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
  
  def notify_absence
  end
  
  def notify_unfilled_absence
  end
  
  def notify_schedule_conflict
  end

  def notify_availability_confirmations_complete
  end
  
  def notify_schedule_ready
  end
  
  # Exit state checks

  # Employee availability needs to be associated to a schedule as well, as users may have multiple
  def check_availabilities
    remaining = this.EmployeeAvailability.where(is_disabled: false, confirmed: false)
    remaining.length
  end
  
  def check_shift_assignment_confirmations
    awaiting
  end

  def active_schedule
    Schedule.find_by(state:6)
  end
  
  def previous_schedule
    schedules = Schedule.where(state:7)
    schedules.max_by do |s|
      s.end_date
    end
  end
end
