class Employee < ActiveRecord::Base
  has_many :shift_assignments
  has_many :shift_exceptions
  has_many :skill_assignments
  has_many :location_assignments
  has_many :skills, through: :skill_assignments
  has_many :locations, through: :location_assignments
  has_many :wages
  has_many :employee_availabilities
    
end
