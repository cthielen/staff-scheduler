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
  
  test "schedules_cannot_overlap should properly identify schedules that overlap" do
    without_access_control do
      s = Schedule.find(1)
      s2 = Schedule.new
      s2.start_date = s.start_date - 1.months
      s2.end_date = s.end_date - 1.months
      assert !s2.save, "should not save schedule when it overlaps with end_date of an existing schedule"
      s2.start_date = s.start_date + 1.months
      s2.end_date = s.end_date + 1.months
      assert !s2.save, "Should not save schedule when it overlaps with start_date of an existing schedule"
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
  
  test "end_date_must_be_later_than_start_date" do
    without_access_control do
      s = Schedule.find(1)
      end_date = s.end_date
      s.end_date = s.start_date
      s.start_date = end_date
      assert !s.save, "Validation should stop a schedule save that has a start_date later than the end_date"
    end
  end
end
