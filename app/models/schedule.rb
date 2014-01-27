class Schedule < ActiveRecord::Base
  using_access_control
  
  has_many :shifts
  has_many :shift_assignments, through: :shifts
  has_many :employee_availabilities
  
  validates :start_date, :end_date, presence: true

  # State Machine
  # ASSUMPTION: Transition Actions go on 'exits' not 'beginnings'
  # ASSUMPTION: schedules cannot overlap
  # ASSUMPTION: process_state will be triggered once a day at 7am by a whenever task
  # Schedule in progress (shifts being created)
  INCOMPLETE_SCHEDULE = 1
  # Action: If schedule is empty, copy old schedule shifts
  # Action: refuse to create if overlaps with other schedule 
  # Exit Condition: Change to state 2 when 'complete' button clicked in schedule planning form
  # Exit Command: Email employees a link to the availability creation form (request_availability_form)
  
  # Initial state after schedule creation
  PENDING_AVAILABILITIES = 2
  # Exit Condition: Change to state 3 when all active employee availabilities have been accounted for.  
  # Exit Command: Email managers that all availabilities have been received and shift_assignments can be filled in (notify_availability_confirmations_complete)
  
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
  # Action: Employee changes availability - change shift_assignments to absent that no longer match - POTENTIALLY VERY DESTRUCTIVE ACTION, WARN EMPLOYEE
  # Action: Manager assigns shift_assignment to employee - email employee for confirmation
  # Action: Manager creates shift without assigning an employee - email all employees to pick up shifts
  # Action: Manager creates shift and assigns an employee - email employee for confirmation
  # Exit Condition: Change to state 7 when schedule end_date is passed

  # Schedule no longer in use
  INACTIVE = 7
  
  # Runs state machine 'loop' of currently active schedule
  def process_state
    case current_state
    
    when INCOMPLETE_SCHEDULE
      # waiting on manager trigger
    when PENDING_AVAILABILITIES
      if check_availabilities == 0
        notify_availability_confirmations_complete
        this.state = 3
      end
    when PENDING_ASSIGNMENTS
      # waiting on manager trigger
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
      if Time.now > this.end_date
        this.state = 7
      end
      
    when INACTIVE
      
    else
      logger.info "Schedule has been put into an invalid state"
    end
  end
    
  # Triggers: Human actions that directly trigger state changes
  def trigger_schedule_created
    self.state = 2
    self.save
  end
  
  def trigger_shift_assignments_created
    self.state = 4
    self.save
  end
      
  # Action requests: Email links to forms to trigger human action
        
  def request_availability_form
    message = "Your hours of availability are needed to begin planning the next schedule. You can submit this information on Staff-Scheduler <link>" 
    subject = "Request for availability"
    recipients = Employee.active_employees.pluck(:email)
    StaffMailer.send_email(message, recipients, subject).deliver
  end
  
  def request_assignment_confirmation_form
    subject = "Shifts assigned to you are awaiting confirmation"
    message = "Shifts have been assigned to you and are awaiting your confirmation. You can confirm your shifts on Staff-scheduler <link>" 
    recipients = Employee.active_employees.pluck(:email)
    StaffMailer.send_email(message, recipients, subject).deliver
  end
  
  def request_shift_exception_fill
     subject = "A shift has become available"
     message = "A shift assignment has been dropped and is available to be claimed. Location: <location>, Skill: <skill>, start time: <start_time>, duration: <duration>. " 
    recipients = Employee.active_employees.pluck(:email)
    StaffMailer.send_email(message, recipients, subject).deliver
  end

  # Action notifications: Emails status update  
  
  def notify_unfilled_absence
    subject = "Unfilled shift tomorrow"
    message = "There is an unfilled absence on tomorrows schedule. You can find more information on Staff-Scheduler <link>" 
    recipients = Employee.active_managers.pluck(:email)
    StaffMailer.send_email(message, recipients, subject).deliver
  end

  def notify_unconfirmed_assignment
    message = "There is an unconfirmed shift assignment on tomorrows schedule. You can find more information on Staff-Scheduler <link>" 
    recipients = Employee.active_managers.pluck(:email)
    StaffMailer.send_email(message, recipients, subject).deliver
  end

  
  def notify_availability_confirmations_complete
    subject = "Schedule is awaiting shift assignments"
    message = "All employee availabilities have been completed. The Schedule is now ready to have shift assignments filled. <link to schedule>"
    recipients = Employee.active_managers.pluck(:email)
    StaffMailer.send_email(message, recipients, subject).deliver
  end
  
  def notify_schedule_ready
    subject = "Schedule planning is complete"
    message = "All shift assignments have been confirmed by employees. The schedule is ready and will begin on <startdate>"
    recipients = Employee.active_managers.pluck(:email)
    StaffMailer.send_email(message, recipients, subject).deliver
  end
  
  # checks
  def check_availabilities
    total = Employee.active_employees.length
    current = self.employee_availabilities.length
    remaining = total - current
  end
  
  def check_shift_assignment_confirmations
    total = self.shift_assignments.length
    current = self.shift_assignments.where(confirmed: true).length
    remaining = total - current
  end

  def check_upcoming_shortages  
    schedule = Schedule.active_schedule
  
    # Whenever will only trigger a calendar check and send notification if a schedule is active  
    if !schedule.blank? 
      shortages = staff_shortages(Schedule.next_working_day(Time.now.tomorrow.to_date))
      if !shortages.blank?
        notify_unfilled_absence
      end
    end
  end

  def staff_shortages(startdate, enddate)
    # for each shift on the specified day in the active schedule'
    shifts = Schedule.active_schedule.shifts.all
    shifts.each do |shift|
      if shift.start_datetime.to_date == day.to_date
        # look through the attached shift assignments and ensure they match end to end 
        # beginning with a 'planned' and 'confirmed' shift that starts at the start time, and ending with a shift that ends at the end time      
      end
    end
  end
  
  def self.active_schedule
    Schedule.find_by(state:6)
  end
  
  def self.previous_schedule
    schedules = Schedule.where(state:7)
    schedules.max_by do |s|
      s.end_date
    end
  end
  
  def self.check_working_day(day)
    # are there any shift assignments on the active schedule, scheduled for tomorrow? next day? next day? stop when you reach the end date of schedule
    schedule = Schedule.active_schedule
    if !schedule.blank?
      schedule.shifts.each do |shift|
        if shift.start_datetime.to_date == day
          return true
        end
      end
    end
    return false
  end
  
end
