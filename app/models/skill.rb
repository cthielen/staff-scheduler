class Skill < ActiveRecord::Base
  has_many :skill_assignments
  has_many :employees, through: :skill_assignments
  has_many :shifts
  
  validates :title, presence: true, uniqueness: true
end
