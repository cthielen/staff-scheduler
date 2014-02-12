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
