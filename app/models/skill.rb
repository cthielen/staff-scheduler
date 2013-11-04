class Skill < ActiveRecord::Base
  has_many :employees, through: :skill_assignments
  has_many :shifts
end
