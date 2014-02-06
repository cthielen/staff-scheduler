class Schedule < ActiveRecord::Base
  using_access_control
  
  has_many :shifts
  has_many :shift_assignments, through: :shifts
  has_many :employee_availabilities
  
  validate :schedules_cannot_overlap, :end_date_must_be_later_than_start_date
  validates :start_date, :end_date, presence: true

  # Runs state machine 'loop' of currently active schedule
  def process_state
    case current_state
    
    when ScheduleStatus::INCOMPLETE_SCHEDULE
      # waiting on manager trigger
    when ScheduleStatus::PENDING_AVAILABILITIES
      if check_availabilities == 0
        StaffMailer.notify_availability_confirmations_complete.deliver
        this.state = 3
      end
    when ScheduleStatus::PENDING_ASSIGNMENTS
      # waiting on manager trigger
    when ScheduleStatus::PENDING_CONFIRMATION
      if check_shift_assignment_confirmations == 0
        StaffMailer.notify_schedule_ready.deliver
        this.state = 5
      end
    when ScheduleStatus::READY
      if Time.now > this.start_date
        this.state = 6
      end
    when ScheduleStatus::ACTIVE
      if Time.now > this.end_date
        this.state = 7
      end
      
    when ScheduleStatus::INACTIVE
      
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

  # Triggered by Whenever schedule
  def self.check_upcoming_shortages  
    schedule = Schedule.active_schedule  
 
    # Will only run if there is a currently active schedule
    if !schedule.blank? 
      shortages = staff_shortages(Schedule.next_working_day(Time.now.tomorrow.to_date, Time.now.tomorrow.to_date))
      if !shortages.blank?
        StaffMailer.notify_unfilled_absence.deliver # Needs to be expanded to accept shortages array and output results in email
      end
    end
  end
  
  # Accepts a date range (to check a single day you can set the same day to startdate and enddate)
  # Returns an array of hashes {start_datetime, end_datetime, shift_id} where shifts were not covered by a (planned or completed) shift_assignment
  def self.staff_shortages(startdate, enddate)
    
    shortages = []
    shifts = Schedule.active_schedule.shifts.all
    
    shifts.each do |shift|
      # Only interested in shifts that fall wtihin the specified date range
      if (shift.start_datetime.to_date >= startdate) && (shift.start_datetime.to_date <= enddate)
        shortages.push( Schedule.shortages_on_shift(shift) )
      end
    end
    
    return shortages
  end
  
  # Accepts a shift, 
  # Returns an array of hashes {start_datetime, end_datetime, shift_id} where there was no coverage (planned or completed) shift_assignment
  def self.shortages_on_shift(shift)
 
    shortages = []
    shortage = {"start_datetime" => nil, "end_datetime" => nil, "shift_id" => shift.id}
    time_marker = shift.start_datetime
    # If no valid shift_assignment is found, time marker increments by 30 minutes and a start time and shift_id is recorded for shortage
    # When a valid shift_assignment is found, time_marker jumps to that assignments end_datetime
    # When a valid shift_assignment is found and a shortage has begun, an end_datetime is recorded, its pushed to the shortages array, and shortage is reset to nil
    
    # Loop ends when all time for the shift has been accounted for
    while time_marker < shift.end_datetime

      assignments = ShiftAssignment.where(shift_id: shift.id, is_confirmed: true, start_datetime: time_marker, shift_assignment_status:{name: ["planned", "completed"]}).all

      # No valid shift_assignments found?
      if assignments.count == 0
        # Start a new shortage or continue existing shortage
        if shortage['start_datetime'].blank?
          shortage['start_datetime'] = time_marker
        end
        time_marker += 30.minutes
      else
        old_time_marker = time_marker

        # Check assignments at this time block to see if any have the right status
        assignments.each do |assignment|
          if (assignment.shift_assignment_status.name == "planned") || (assignment.shift_assignment_status.name == "completed")
            # Valid shift_assignment found 
            
            # End and record an existing shortage?
            if shortage['start_datetime'].present?
              shortage['end_datetime'] = time_marker
              shortages.push(shortage)
              shortage = {"start_datetime" => nil, "end_datetime" => nil, "shift_id" => shift.id}
            end
            time_marker = assignment.end_datetime
            break
          end
        end
        # No valid shift_assignments found in assignments for this time?
        if time_marker == old_time_marker
          # Start a new shortage or continue existing shortage
          if shortage['start_datetime'].blank?
            shortage['start_datetime'] = time_marker
          end
          time_marker += 30.minutes
        end
      end              
    end
    return shortages
  end

  # Returns the current active schedule
  def self.active_schedule
    Schedule.find_by(state:6)
  end
  
  # Returns the last completed schedule
  def self.previous_schedule
    schedules = Schedule.where(state:7)
    schedules.max_by do |s|
      s.end_date
    end
  end
  
  # Returns true if the specified day has shifts associated to it, might be deprecated with current design
  def self.check_working_day(day)
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
 
  # Validation
  def schedules_cannot_overlap
    Schedule.all.each do |schedule|
      if (self.start_date >= schedule.start_date) && (self.start_date <= schedule.end_date)
        errors.add(:start_date, "schedule can't start in the middle of an existing")
      elsif (self.end_date >= schedule.start_date) && (self.end_date <= schedule.end_date)
        errors.add(:end_date, "schedule can't end in the middle of an existing schedule")
      end
    end
  end 
  
  def end_date_must_be_later_than_start_date
    if self.end_date and (self.end_date < self.start_date)
      errors.add(:end_date, "End date must come after start date")
    end
  end
end

module ScheduleStatus

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
end
