class Employee < ActiveRecord::Base
  using_access_control
  
  has_many :shift_assignments, dependent: :destroy
  has_many :shift_exceptions, dependent: :destroy
  has_many :skill_assignments, dependent: :destroy
  has_many :location_assignments, dependent: :destroy
  has_many :skills, through: :skill_assignments
  has_many :locations, through: :location_assignments
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
  
  # will return an array of eligable employees that could take the shift
  def self.available_employees(shift)
    Employee.all.each do |employee|
      
    end
  end
  
  # returns the number of hours the specified employee is scheduled to work this week
  def hours_this_week(employee)
    total_hours = 0
    self.shift_assignments.each do |assignment|
      if (assignment.shift_assignment_status.name == "planned") || (assignment.shift_assignment_status.name == "schedule")
        total_hours += (assignment.end_datetime - assignment.start_atetime) / 3600
      end
    end
    total_hours
  end
end
