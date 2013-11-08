class Skill < ActiveRecord::Base
  has_many :skill_assignments
  has_many :employees, through: :skill_assignments
  has_many :shifts
end
