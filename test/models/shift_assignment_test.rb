require 'test_helper'

class ShiftAssignmentTest < ActiveSupport::TestCase

  test "Should be able to access Shift_assignment associated models" do
    s = ShiftAssignment.find(1)
    s.shift
    s.employee
  end

end
