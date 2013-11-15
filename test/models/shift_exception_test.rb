require 'test_helper'

class ShiftExceptionTest < ActiveSupport::TestCase

  test "Should be able to access Shift_exception associated models" do
    s = ShiftException.find(1)
    s.shift
    s.employee
  end
  
end
