class Employee < ActiveRecord::Base
  using_access_control
  
  has_many :shift_assignments, dependent: :destroy
  has_many :shift_exceptions, dependent: :destroy
  has_many :location_assignments, dependent: :destroy
  has_many :skill_assignments, dependent: :destroy
  has_many :skills, :through => :skill_assignments
  has_many :locations, :through => :location_assignments
  has_many :shifts, through: :shift_assignments
  has_many :wages, dependent: :destroy
  has_many :employee_availabilities, dependent: :destroy
  has_one :user
  
  validates :max_hours, :email, :name, presence: true
  validates :is_disabled, inclusion: { in: [true, false] }
  
  def self.active_managers
    Employee.joins(:user).where(:users => {:is_manager => false, :disabled => false})
  end
  
  def self.active_employees
    Employee.joins(:user).where(:users => {:is_manager => true, :disabled => false})  
  end
 
  # accepts a date, returns the number of hours the employee will work or has worked on the week of that date
  def hours_working(date)
    total_hours = 0
    week_start = date.at_beginning_of_week
    week_end = date.at_end_of_week
    
    # Only shift assignments from the week of the specified date
    self.shift_assignments.where(start_datetime: week_start .. week_end) do |assignment|
      if (assignment.shift_assignment_status.name == "planned") || (assignment.shift_assignment_status.name == "schedule")
        total_hours += (assignment.end_datetime - assignment.start_atetime) / 3600
      end
    end
    total_hours
  end
  
  # accepts a shift, returns true or false if employee is eligible to work. Accounts for skills, locations, weekly hour cap and existing shift assignment conflicts.
  # Note: unconfirmed and planned shift_assignments at the same time as 'shift' will make the employee ineligible to work shift.
  def eligible_to_work(shift)
    shift_hours = (shift.end_datetime - shift.start_datetime) / 3600 # converts seconds to hours
    # Ensure availability overlaps completely with shift
    if true
    end
    # Ensure employee is not working those hours already 
    self.shift_assignments.each do |assignment|
      if (assignment.shift_assignment_status.name == "planned") || (assignment.shift_assignment_status.name == "completed")
        unless (shift.start_datetime < assignment.start_datetime) && (shift.end_datetime <= assignment.start_datetime)
          return false
        end
        unless (shift.start_datetime >= assignment.end_datetime) && (shift.end_datetime > assignment.end_datetime)
          return false
        end        
      end
    end

    # Ensure employee does not exceed weekly hours
    if (self.hours_working(shift.start_datetime.to_date) + shift_hours) < self.max_hours
      # Ensure employee has necessary skill
      if self.skills.where(id: shift.skill_id).count
        # Ensure employee has necessary location
        if self.locations.where(id: shift.location_id).count
          return true
        end
      end
    end
    return false
  end  
end
