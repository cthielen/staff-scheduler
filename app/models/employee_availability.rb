class EmployeeAvailability < ActiveRecord::Base
  after_save :compact_availabilities
  
  using_access_control
  
  belongs_to :employee
  belongs_to :schedule

  validates :start_datetime, :end_datetime, :schedule_id, presence: true

  def compact_availabilities
    EmployeeAvailability.where(schedule_id: self.schedule_id, employee_id: self.employee_id).each do |availability|
      if (availability.start_datetime == self.end_datetime) 
        availability.start_datetime = self.start_datetime
        self.destroy
        availability.save!   
        break     
      end
      if (availability.end_datetime == self.start_datetime)
        availability.end_datetime = self.end_datetime
        self.destroy 
        availability.save!
        break
      end
    end
  end
end
