require 'test_helper'

class WageTest < ActiveSupport::TestCase

  test "Should be able to access Wage associated models" do
    w = Wage.find(1)
    w.employee
  end

end
