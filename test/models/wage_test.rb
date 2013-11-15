require 'test_helper'

class WageTest < ActiveSupport::TestCase

  test "Should be able to access Wage associated models" do
    w = Wage.find(1)
    w.employee
  end

  test "Should not save model with missing employee field" do
    w = Wage.new
    refute w.save, " |||||ERROR||||| Saved the message without subject"
  end

end
