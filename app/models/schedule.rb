class Schedule < ActiveRecord::Base
  using_access_control
  before_save :set_schedule_name

  has_many :shifts, :dependent => :destroy
  has_many :shift_assignments, through: :shifts
  has_many :employee_availabilities
  has_many :employees, through: :employee_schedules
  has_many :employee_schedules

  belongs_to :organization

  validate :schedules_cannot_overlap, :end_date_must_be_later_than_start_date
  validates :start_date, :end_date, :organization_id, presence: true

  accepts_nested_attributes_for :shifts

  def add_employees=(employees_arr)
    employees_arr.each do |e|
      employee = Employee.find_or_create_by_email(email: e[:email], name: e[:name])
      self.employees << employee unless self.employees.include?(employee) # Avoid duplicates
    end
  end

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
  def daily_scheduled_tasks
    check_upcoming_shortages
    notify_schedule_ending
  end

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

  def self.notify_schedule_ending
    schedule = Schedule.active_schedule
    if Time.now.to_date + 2.weeks > schedule.end_date
      StaffMailer.notify_schedule_ending.deliver
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
        shortages.push( shift.shortages_on_shift )
      end
    end

    return shortages
  end

  # Returns the current active schedule
  def self.active_schedules
    Schedule.where("state < ?", 7)
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
    if self.start_date.present? && self.end_date.present?
      Schedule.all.each do |schedule|
        if (self.start_date >= schedule.start_date) && (self.start_date <= schedule.end_date) && (schedule.id != self.id)
          errors.add(:start_date, "schedule can't start in the middle of an existing schedule")
        elsif (self.end_date >= schedule.start_date) && (self.end_date <= schedule.end_date) && (schedule.id != self.id)
          errors.add(:end_date, "schedule can't end in the middle of an existing schedule")
        end
      end
    end
  end

  def end_date_must_be_later_than_start_date
    if self.end_date and (self.end_date < self.start_date)
      errors.add(:end_date, "End date must come after start date")
    end
  end

  def set_schedule_name
    if self.name.blank?
      self.name = "#{start_date.strftime('%b %d, %Y')} - #{end_date.strftime('%b %d, %Y')}"
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
