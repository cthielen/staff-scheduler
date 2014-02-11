require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  test "Should be able to access Location associated models" do
    without_access_control do
      l = Location.find(1)
      l.location_assignments
      l.employees
      l.shifts
    end
  end
  
  test "Should destroy location_assignments when location is destroyed" do
    without_access_control do
      l = Location.find(1)
      a = l.location_assignments
      l.destroy
      assert !a.exists?, "location_assignments still exist after location was destroyed"
    end
  end
  
end
