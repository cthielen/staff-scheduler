require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase

  test "Should be able to access Schedule associated models" do
    s = Schedule.find(1)
    s.shifts
  end
  
  test "Should destroy shifts when schedule is destroyed" do
    s = Schedule.find(1)
    sh = s.shifts
    s.destroy
    assert !sh.exists?, "shifts still exist after schedule was destroyed"
  end
   
end
