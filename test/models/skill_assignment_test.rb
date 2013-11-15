require 'test_helper'

class SkillAssignmentTest < ActiveSupport::TestCase
  
  test "Should be able to access Skill_assignment associated models" do
    s = SkillAssignment.find(1)
    s.skill
    s.employee
  end
end
