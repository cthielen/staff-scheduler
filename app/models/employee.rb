class Employee < ActiveRecord::Base
  using_access_control
  
  has_many :shift_assignments, dependent: :destroy
  has_many :location_assignments, dependent: :destroy
  has_many :skill_assignments, dependent: :destroy
  has_many :skills, :through => :skill_assignments
  has_many :locations, :through => :location_assignments
  has_many :shifts, through: :shift_assignments
  has_many :wages, dependent: :destroy
  has_many :employee_availabilities, dependent: :destroy
  has_one :user
  has_attached_file :profile

  validates :max_hours, :email, :name, presence: true
  validates :is_disabled, inclusion: { in: [true, false] }
  
  def self.active_managers
    Employee.joins(:user).where(:users => {:is_manager => false, :disabled => false})
  end
  
  def self.active_employees
    Employee.joins(:user).where(:users => {:is_manager => true, :disabled => false})  
  end
 
  # Accepts a date, returns the number of hours the employee will work or has worked on the week of that date
  def hours_working(date)
    total_hours = 0
    week_start = date.at_beginning_of_week
    week_end = date.at_end_of_week
    
    # Only shift assignments from the week of the specified date
    self.shift_assignments.where(start_datetime: week_start .. week_end) do |assignment|
      if scheduled?
        total_hours += (assignment.end_datetime - assignment.start_atetime) / 3600
      end
    end
    total_hours
  end
  
  # Accepts a shift, start_timedate, and end_timedate that denote a fragment of that shift, 
  # Returns true if the employee is eligible to work on that shift fragment. 
  # Accounts for skills, locations, availability, max hours, and existing shift assignment conflicts.
  # Note: unconfirmed and planned shift_assignments at the same time as 'shift' will make the employee ineligible to work shift.
  def eligible_to_work(shift, fragment_start, fragment_end)
    shift_hours = (fragment_end - fragment_start) / 3600 # converts seconds to hours
    
    # Ensure availability overlaps completely with shift
    unless self.available_to_work(shift, fragment_start, fragment_end)
      return false
    end

    # Ensure employee is not working those hours already 
    self.shift_assignments.each do |assignment|
      if scheduled?
        unless (fragment_start < assignment.start_datetime) && (fragment_end <= assignment.start_datetime)
          return false
        end
        unless (fragment_start >= assignment.end_datetime) && (fragment_end > assignment.end_datetime)
          return false
        end        
      end
    end

    # Ensure employee does not exceed weekly hours
    if (self.hours_working(fragment_start.to_date) + shift_hours) < self.max_hours
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
  
  # Accepts a shift, shift fragment start, and shift fragmnet end, returns true if employee is avaialble to work
  # NOTE: Checks only against employee availability, not other eligibility criteria
  def available_to_work(shift, fragment_start, fragment_end)  
    employee_availabilities.where(schedule_id: shift.schedule_id).each do |availability|
      if (availability.start_datetime <= fragment_start) && (availability.end_datetime >= fragment_end)
        return true
      end
    end
    return false
  end
  
  # Returns gravatar URL if it exists for the employee's email, otherwise returns nil
  def gravatar
    gravatar = "http://gravatar.com/avatar/#{Digest::MD5.hexdigest(email.strip.downcase)}.png?d=404"
    uri = URI.parse(gravatar)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    if (response.code.to_i == 404)
      return nil
    else
      return gravatar
    end 
  end
end
