class SkillAssignment < ActiveRecord::Base
  using_access_control
  
  belongs_to :employee
  belongs_to :skill
  
  validates :skill, presence: true
  validates :employee_id, :skill_id, presence: true
end
