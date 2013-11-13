require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase

  test "Should be able to access Employee associated models" do
    e = Employee.find(1)
    e.skill_assignments
    e.skills
    e.shift_assignments
    e.shift_exceptions
    e.locations
    e.location_assignments
    e.wages
    e.employee_availabilities
  end
  
  test "Should destroy wages when employee is destroyed" do
    e = Employee.find(1)
    w = e.wages
    e.destroy
    assert !w.exists?, "Wages still exist after employee was destroyed"
  end
  
  test "Should destroy shift_assignments when employee is destroyed" do
    e = Employee.find(1)
    s = e.shift_assignments
    e.destroy
    assert !s.exists?, "shift_assignments still exist after employee was destroyed"
  end

  test "Should destroy shift_exceptions when employee is destroyed" do
    e = Employee.find(1)
    s = e.shift_exceptions
    e.destroy
    assert !s.exists?, "shift_exceptions still exist after employee was destroyed"
  end  
  
  test "Should destroy skill_assignments when employee is destroyed" do
    e = Employee.find(1)
    s = e.skill_assignments
    e.destroy
    assert !s.exists?, "skill_assignments still exist after employee was destroyed"
  end
  
  test "Should destroy location_assignments when employee is destroyed" do
    e = Employee.find(1)
    l = e.location_assignments
    e.destroy
    assert !l.exists?, "location_assignments still exist after employee was destroyed"
  end  
  
end
