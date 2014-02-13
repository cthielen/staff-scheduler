require 'test_helper'

class ShiftTest < ActiveSupport::TestCase

  test "Should be able to access Shift associated models" do
    without_access_control do
      s = Shift.find(1)
      s.shift_assignments
      s.skill
      s.location
      s.schedule
    end
  end
  
  test "Should destroy shift_assignments when employee is destroyed" do
    without_access_control do
      s = Shift.find(1)
      a = s.shift_assignments
      s.destroy
      assert !a.exists?, "shift_assignments still exist after shift was destroyed"
    end
  end
#  test "shortages_on_shift should detect shortages"
#    without_access_control do
#      s = Shift.find(2)
#     # assert s.shortages_on_shift.blank?
#    end
#  end
end
