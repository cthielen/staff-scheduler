require 'test_helper'

class LocationAssignmentTest < ActiveSupport::TestCase

  test "Should be able to access Location_assignment associated models" do
    s = LocationAssignment.find(1)
    s.location
    s.employee
  end
  
end
