require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "Should be able to access User associated models" do
    u = User.find(1)
    u.employee
  end
  
end
