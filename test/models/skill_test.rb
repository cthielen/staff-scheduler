require 'test_helper'

class SkillTest < ActiveSupport::TestCase

  test "Should be able to access Shift associated models" do
    without_access_control do
      s = Skill.find(1)
      s.skill_assignments
      s.employees
      s.shifts
    end
  end
  
  test "Should destroy skill_assignments when skill is destroyed" do
    without_access_control do
      s = Skill.find(1)
      a = s.skill_assignments
      s.destroy
      assert !a.exists?, "skill_assignments still exist after skill was destroyed"
    end
  end
end
