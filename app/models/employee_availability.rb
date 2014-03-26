class EmployeeAvailability < ActiveRecord::Base
  using_access_control
  
  after_save :compact_availabilities
    
  belongs_to :employee
  belongs_to :schedule

  validates :start_datetime, :end_datetime, :schedule_id, presence: true
  # validate :availability_should_fall_within_a_defined_shift

  scope :by_schedule, lambda { |schedule| where(schedule_id: schedule) unless schedule.blank? }
  scope :by_skill, lambda { |skill| joins(:employee => :skills).where('skill_assignments.skill_id = ?', skill).uniq unless skill.blank? }
  scope :by_location, lambda { |location| joins(:employee => :locations).where('location_assignments.location_id = ?', location).uniq unless location.blank? }

  def availability_should_fall_within_a_defined_shift
    self.schedule.shifts.each do |shift|
      if self.start_datetime >= shift.start_datetime and self.end_datetime <= shift.end_datetime
        # A shift was found, save is allowed
        return
      end
    end
    # If no shifts found for the selected range, add the error
    errors.add(:outside_shift, "Availability must fall wtihin a shift")
  end
  def compact_availabilities
    EmployeeAvailability.where(schedule_id: self.schedule_id, employee_id: self.employee_id).each do |availability|
      if (availability.start_datetime == end_datetime) 
        availability.start_datetime = start_datetime
        availability.save!        
        self.destroy
        break
      end
      if (availability.end_datetime == start_datetime)
        availability.end_datetime = end_datetime
        availability.save!
        self.destroy 
        break
      end
    end
  end
end
