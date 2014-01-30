class Shift < ActiveRecord::Base
  using_access_control
  
  belongs_to :skill
  belongs_to :location
  belongs_to :schedule, touch: true
  has_many :shift_assignments, dependent: :destroy
  has_many :shift_exceptions, dependent: :destroy
  
  validates :start_datetime, :end_datetime, :location_id, :skill_id, :schedule_id, presence: true  
  validates :is_mandatory, :inclusion => {:in => [true, false]}
  
  scope :by_schedule, lambda { |schedule| where(schedule_id: schedule) unless schedule.nil? }
  scope :by_skill, lambda { |skill| where(skill_id: skill) unless skill.nil? }
  scope :by_location, lambda { |location| where(location_id: location) unless location.nil? }
end
