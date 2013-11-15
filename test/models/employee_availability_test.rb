require 'test_helper'

class EmployeeAvailabilityTest < ActiveSupport::TestCase

  test "Should be able to access Employee_availability associated models" do
    ea = EmployeeAvailability.find(1)
    ea.employee
  end
  
end
