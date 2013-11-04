class ShiftException < ActiveRecord::Base
  belongs_to :employee
  belongs_to :shift
end
