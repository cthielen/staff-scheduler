class Shift < ActiveRecord::Base
  belongs_to :skill
  belongs_to :location
  belongs_to :schedule, touch: true
  has_many :shift_assignments, dependent: :destroy
  has_many :shift_exceptions, dependent: :destroy
  
  validates :start_datetime, :end_datetime, :is_mandatory, :location_id, :skill_id, :schedule_id, presence: true  
end
