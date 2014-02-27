class EmployeeAvailability < ActiveRecord::Base
  using_access_control
  
  after_save :compact_availabilities
    
  belongs_to :employee
  belongs_to :schedule

  validates :start_datetime, :end_datetime, :schedule_id, presence: true

  scope :by_schedule, lambda { |schedule| where(schedule_id: schedule) unless schedule.blank? }
  scope :by_skill, lambda { |skill| joins(:employee => :skills).where('skill_assignments.skill_id = ?', skill).uniq unless skill.blank? }
  scope :by_location, lambda { |location| joins(:employee => :locations).where('location_assignments.location_id = ?', location).uniq unless location.blank? }

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
