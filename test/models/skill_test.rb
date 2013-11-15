require 'test_helper'

class SkillTest < ActiveSupport::TestCase

  test "Should be able to access Shift associated models" do
    s = Skill.find(1)
    s.skill_assignments
    s.employees
    s.shifts
  end
  
  test "Should destroy skill_assignments when skill is destroyed" do
    s = Skill.find(1)
    a = s.skill_assignments
    s.destroy
    assert !a.exists?, "skill_assignments still exist after skill was destroyed"
  end

end
