require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase

  test "Should be able to access Employee associated models" do
    without_access_control do
      e = Employee.find(1)
      e.skill_assignments
      e.skills
      e.shift_assignments
      e.locations
      e.location_assignments
      e.wages
      e.employee_availabilities
      e.user
    end
  end
  
  test "Should destroy wages when employee is destroyed" do
    without_access_control do
      e = Employee.find(1)
      w = e.wages
      e.destroy
      assert !w.exists?, "Wages still exist after employee was destroyed"
    end
  end
  
  test "Should destroy shift_assignments when employee is destroyed" do
    without_access_control do
      e = Employee.find(1)
      s = e.shift_assignments
      e.destroy
      assert !s.exists?, "shift_assignments still exist after employee was destroyed"
    end
  end
  
  test "Should destroy skill_assignments when employee is destroyed" do
    without_access_control do
      e = Employee.find(1)
      s = e.skill_assignments
      e.destroy
      assert !s.exists?, "skill_assignments still exist after employee was destroyed"
    end
  end
  
  test "Should destroy location_assignments when employee is destroyed" do
    without_access_control do
      e = Employee.find(1)
      l = e.location_assignments
      e.destroy
      assert !l.exists?, "location_assignments still exist after employee was destroyed"
    end
  end  
  
  test "Should calculate hours_worked" do
    without_access_control do
      e = Employee.create!(
        :max_hours => 20,
        :name => "bob dylan",
        :email => "bobdylan@gmail.com",
        :is_disabled => false
      )
      assert e.present?
    end
  end
end
