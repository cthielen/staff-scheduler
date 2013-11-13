class Schedule < ActiveRecord::Base
  has_many :shifts
  
  validates :start_date, :end_date, presence: true
end
