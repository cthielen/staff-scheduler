class Shift < ActiveRecord::Base
  belongs_to :skill
  belongs_to :location
  has_many :shift_assignments
  has_many :shift_exceptions
end
