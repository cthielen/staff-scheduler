require 'test_helper'

class ShiftTest < ActiveSupport::TestCase

  test "Should be able to access Shift associated models" do
    s = Shift.find(1)
    s.shift_assignments
    s.skill
    s.shift_exceptions
    s.location
    s.schedule
  end
  
  test "Should destroy shift_assignments when employee is destroyed" do
    s = Shift.find(1)
    a = s.shift_assignments
    s.destroy
    assert !a.exists?, "shift_assignments still exist after shift was destroyed"
  end

  test "Should destroy shift_exceptions when employee is destroyed" do
    s = Shift.find(1)
    e = s.shift_exceptions
    s.destroy
    assert !e.exists?, "shift_exceptions still exist after shift was destroyed"
  end
 
end
