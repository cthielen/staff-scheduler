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
end
