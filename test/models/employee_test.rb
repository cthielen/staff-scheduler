require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase
  test "Should be able to access Employee associated models" do
    e = Employee.new
    e.skill_assignments
    e.skills
    e.shift_assignments
    e.shift_exceptions
    e.locations
    e.location_assignments
    e.wages
    e.employee_availabilities
  end
  
end
