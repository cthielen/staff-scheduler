class Organization < ActiveRecord::Base
  using_access_control
  
  has_many :employees
  has_many :schedules
  
  validates :title, presence: true
  
end
