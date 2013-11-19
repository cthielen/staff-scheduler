class Skill < ActiveRecord::Base
  using_access_control
  
  has_many :skill_assignments, dependent: :destroy
  has_many :employees, through: :skill_assignments
  has_many :shifts
  
  validates :title, presence: true, uniqueness: true
end
