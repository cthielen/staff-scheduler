class Schedule < ActiveRecord::Base
  using_access_control
  
  has_many :shifts
  
  validates :start_date, :end_date, presence: true
end
