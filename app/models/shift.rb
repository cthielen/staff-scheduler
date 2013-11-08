class Shift < ActiveRecord::Base
  belongs_to :skill
  belongs_to :location
  has_many :shift_assignments
  has_many :shift_exceptions
  
  validates :start_datetime, :end_datetime, :is_mandatory, :location_id, :skill_id, presence: true  
end
