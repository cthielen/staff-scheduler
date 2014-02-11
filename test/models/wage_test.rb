require 'test_helper'

class WageTest < ActiveSupport::TestCase

  test "Should be able to access Wage associated models" do
    without_access_control do
      w = Wage.find(1)
      w.employee
    end
  end

  test "Should not save model with missing employee field" do
    without_access_control do
      w = Wage.new
      refute w.save, " |||||ERROR||||| Saved the message without subject"
    end
  end

end
