class Shift < ActiveRecord::Base
  using_access_control
  
  belongs_to :skill
  belongs_to :location
  belongs_to :schedule, touch: true
  has_many :shift_assignments, dependent: :destroy

  validates :schedule, :location, :skill, presence: true 
  validate :shift_must_fit_inside_schedule, :end_date_must_be_later_than_start_date
  validates :start_datetime, :end_datetime, :location_id, :skill_id, :schedule_id, presence: true
  validates :is_mandatory, :inclusion => {:in => [true, false]}
  
  scope :by_schedule, lambda { |schedule| where(schedule_id: schedule) unless schedule.nil? }
  scope :by_skill, lambda { |skill| where(skill_id: skill) unless skill.nil? }
  scope :by_location, lambda { |location| where(location_id: location) unless location.nil? }
 
  # will return an array of eligible employees that could take the shift
  def available_employees
    employees = []
    # Only active employees
    Employee.where(is_disabled: false).each do |employee|
      if employee.eligible_to_work(self)
        employees.push(employee)
      end
    end
    employees
  end  

  # Returns an array of hashes {start_datetime, end_datetime, shift_id} where there was no coverage (planned or completed) shift_assignment
  def shortages_on_shift
 
    shortages = []
    shortage = {"start_datetime" => nil, "end_datetime" => nil, "shift_id" => self.id}
    time_marker = self.start_datetime
    # If no valid shift_assignment is found, time marker increments by 30 minutes and a start time and shift_id is recorded for shortage
    # When a valid shift_assignment is found, time_marker jumps to that assignments end_datetime
    # When a valid shift_assignment is found and a shortage has begun, an end_datetime is recorded, its pushed to the shortages array, and shortage is reset to nil
    
    # Loop ends when all time for the shift has been accounted for
    while time_marker < self.end_datetime

      assignments = ShiftAssignment.where(shift_id: self.id, is_confirmed: true, start_datetime: time_marker, shift_assignment_status:{name: ["planned", "completed"]}).all

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
          if scheduled?
            # Valid shift_assignment found 
            
            # End and record an existing shortage?
            if shortage['start_datetime'].present?
              shortage['end_datetime'] = time_marker
              shortages.push(shortage)
              shortage = {"start_datetime" => nil, "end_datetime" => nil, "shift_id" => self.id}
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
  
  def end_date_must_be_later_than_start_date
    if self.end_datetime and (self.end_datetime < self.start_datetime)
      errors.add(:end_datetime, "End date must come after start date")
    end
  end
  
  def shift_must_fit_inside_schedule
    if self.schedule.present?
      if self.start_datetime.to_date < self.schedule.start_date
        errors.add(:start_datetime, "shift_assignment start_datetime must fall wtihin its schedule")
      elsif self.end_datetime.to_date > self.schedule.end_date
        errors.add(:end_datetime, "shift_assignment end_datetime must fall wtihin its schedule")    
      end
    end  
  end
end
