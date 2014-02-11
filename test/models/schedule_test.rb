require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase

  test "Should be able to access Schedule associated models" do
    without_access_control do
      s = Schedule.find(1)
      s.shifts
    end
  end
  
  test "Should destroy shifts when schedule is destroyed" do
    without_access_control do
      s = Schedule.find(1)
      sh = s.shifts
      s.destroy
      assert !sh.exists?, "shifts still exist after schedule was destroyed"
    end
  end
    
  test "schedules_cannot_overlap should exclude comparing the saved schedule against itself" do
    without_access_control do
      s = Schedule.find(1)
      assert s.present?, "Schedule was not found in fixture"
      s.end_date = s.end_date - 1.days
      assert s.save, "Validation should not compare schedule against itself after a change, #{s.inspect}"
    end
  end
end
